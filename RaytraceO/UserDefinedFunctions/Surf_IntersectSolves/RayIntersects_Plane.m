
function IntersectPositionsNx3 = RayIntersects_Plane(rayPositionsNx3,rayDirectionsNx3,allowedRaysFcnHndl,planePoint1x3,planeNormal1x3)
N=size(rayPositionsNx3,1);
p=rayPositionsNx3-ones(N,1)*planePoint1x3;
s=rayDirectionsNx3;
n=planeNormal1x3;

distance=-(n(1)*p(:,1) + n(2)*p(:,2) + n(3)*p(:,3))./(n(1)*s(:,1) + n(2)*s(:,2) + n(3)*s(:,3));
distance(distance<=0)=inf; %keep only intersects that are in front of the rays (rays don't intersect surfaces that are behind them)

IntersectPositionsNx3=p+(distance*ones(1,3)).*s;

%clear out imaginary and NaN solutions
IntersectPositionsNx3(imag(IntersectPositionsNx3)~=0)=inf;
IntersectPositionsNx3(isnan(IntersectPositionsNx3))=inf;

%apply the supplied windowing function
IntersectPositionsNx3(~allowedRaysFcnHndl(IntersectPositionsNx3+ones(N,1)*planePoint1x3),:)=inf;
% % for checking purposes
% figure; plot3(IntersectPositionsNx3(:,1),IntersectPositionsNx3(:,2),IntersectPositionsNx3(:,3),'Marker','o','MarkerFaceColor','b')

%  check the solves and if any are too far away from the plane surface, numerically bring them closer (go along the ray direction and add on some distance or take it off) 
    n=n/norm(n);%normalize n
    closeness=sum(IntersectPositionsNx3.*(ones(N,1)*n),2);
    IndicesToGetCloser = all([ abs(closeness)>4e-14 , isfinite(closeness) ],2);
    if any(IndicesToGetCloser)
        %initialize some things
        normedRayDir=s./(sqrt(sum(s.^2,2))*ones(1,3));
        waytogo=-1./sum((normedRayDir.*(ones(N,1)*n)),2); %these are cosine factors that help the approximation go faster
    end
    count=1; 
    while any(IndicesToGetCloser)
        II=IndicesToGetCloser;%rename 
        newIntersectPositionsNx3=((waytogo(II).*closeness(II))*ones(1,3)).*normedRayDir(II,:)+IntersectPositionsNx3(II,:);
        N=size(newIntersectPositionsNx3,1);
        newcloseness=sum(newIntersectPositionsNx3.*(ones(N,1)*n),2);
        gotSigCloser=abs(newcloseness)<(.8*abs(closeness(II)));%significantly closer means it got more than 20 percent closer than before
        II(II)=gotSigCloser; %use this for updating intersects and closeness (the ones that got significantly closer get updated)
        IntersectPositionsNx3(II,:)=newIntersectPositionsNx3(gotSigCloser,:); %if it didn't get significantly closer, then keep the old intersect, otherwise update to the new intersect
        closeness(II)=newcloseness(gotSigCloser); %likewise, keep the old closeness if it didn't get significantly close, otherwise update to the new closeness
        II(II)=abs(newcloseness(gotSigCloser))>4e-14; %only keep updating for those that haven't met this threshold
        IndicesToGetCloser=II;
        
        count=count+1;
        if count>100
            break;
        end
    end
cm=max(abs(closeness(isfinite(closeness)))); %report any non-close rays
if cm>4e-14
    disp('At least one ray fell short of optimal surface closeness')
    disp([num2str(count),' iterations were used in attempting to reduce closeness']);
end

%shift IntersectPositionsNx3 back out to where the plane point actually is 
IntersectPositionsNx3=IntersectPositionsNx3+ones(size(rayPositionsNx3,1),1)*planePoint1x3;










%old code

%{
function IntersectPositionsNx3 = RayIntersects_Plane(rayPositionsNx3,rayDirectionsNx3,allowedRaysFcnHndl,planePoint1x3,planeNormal1x3)
N=size(rayPositionsNx3,1);
p=rayPositionsNx3;
d=rayDirectionsNx3;
c=planePoint1x3';
n=planeNormal1x3';

[~,ind]=max(abs(rayDirectionsNx3),[],2);
ind2=ind==2;
ind3=ind==3;

d(ind2,:)=circshift(d(ind2,:),[0,-1]);
d(ind3,:)=circshift(d(ind3,:),[0,-2]);
p(ind2,:)=circshift(p(ind2,:),[0,-1]);
p(ind3,:)=circshift(p(ind3,:),[0,-2]);

X1=(n(mod(ind,3)+1).*(c(mod(ind,3)+1).*d(:,1) - d(:,1).*p(:,2) + d(:,2).*p(:,1)) + n(mod(ind+1,3)+1).*(c(mod(ind+1,3)+1).*d(:,1) - d(:,1).*p(:,3) + d(:,3).*p(:,1)) + c(ind).*d(:,1).*n(ind))./(d(:,1).*n(ind) + d(:,2).*n(mod(ind,3)+1) + d(:,3).*n(mod(ind+1,3)+1));

YZ1=d(:,2:3)./[d(:,1),d(:,1)].*([X1(:,1),X1(:,1)]-[p(:,1),p(:,1)])+p(:,2:3);
clear p d
IntersectPositionsNx3=[X1,YZ1];
clear X1 YZ1

%Shift indices back to normal
IntersectPositionsNx3(ind2,:)=circshift(IntersectPositionsNx3(ind2,:),[0,1]);
IntersectPositionsNx3(ind3,:)=circshift(IntersectPositionsNx3(ind3,:),[0,2]);


pointsnotahead = sum((IntersectPositionsNx3-rayPositionsNx3).*rayDirectionsNx3,2)<0;
IntersectPositionsNx3(pointsnotahead,:)=inf;
IntersectPositionsNx3(isnan(IntersectPositionsNx3))=inf;
% IntersectPositionsNx3(~allowedRaysFcnHndl(IntersectPositionsNx3),:)=inf;


%{
%This is code for testing the intersects to verify they are accurate
%Uncomment this section if testing is desired
disp .
disp **********TESTtheRESULTS_plane_intersect*******
disp .
%test the results
rd=rayDirectionsNx3;
rd(abs(rd)<1e-10)=nan;
ip=IntersectPositionsNx3;
ip(~isfinite(ip))=nan;

%test that they are on the line
shouldhavesamecolumns=(ip-rayPositionsNx3)./(rd);
rowsoffline=any([any(abs(diff(shouldhavesamecolumns,1,2))>1e-9,2),shouldhavesamecolumns<0]);
if any(rowsoffline)
    rpo=rayPositionsNx3(rowsoffline,:);
    rdo=rayDirectionsNx3(rowsoffline,:);
    rio=IntersectPositionsNx3(rowsoffline,:);
    disp('Here is one ray that went off the line:')
    disp('The starting ray position:');
    disp(rpo(1,:));
    disp('The starting ray direction:');
    disp(rdo(1,:));
    disp('The intersect point');
    disp(rio(1,:));
end

disp('These should all be close to 0, or inf, or nan')
sum((ip-ones(N,1)*planePoint1x3).*(ones(N,1)*planeNormal1x3),2)
disp ******END_OFTHE_TEST********

end
%}

%}

