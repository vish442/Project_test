function IntersectPositionsNx3 = RayIntersects_Sphere(rayPositionsNx3,rayDirectionsNx3,allowedRaysFcnHndl,sphereCenter1x3,sphereRadius) 

N=size(rayPositionsNx3,1);
p=rayPositionsNx3-ones(N,1)*sphereCenter1x3;
s=rayDirectionsNx3;
r=sphereRadius;

A=(s(:,1).^2 + s(:,2).^2 + s(:,3).^2);
B=(2*p(:,1).*s(:,1) + 2*p(:,2).*s(:,2) + 2*p(:,3).*s(:,3));
C=p(:,1).^2 + p(:,2).^2 + p(:,3).^2 - r^2;

distance1=(-B+sqrt(B.^2-4*A.*C))./A/2;
distance2=(-B-sqrt(B.^2-4*A.*C))./A/2;
IntersectPositionsNx3=p+(distance1*ones(1,3)).*s;
IntersectPositions2nd=p+(distance2*ones(1,3)).*s;

%clear out imaginary and NaN solutions
IntersectPositionsNx3(imag(IntersectPositionsNx3)~=0)=inf;
IntersectPositions2nd(imag(IntersectPositions2nd)~=0)=inf;
IntersectPositionsNx3(isnan(IntersectPositionsNx3))=inf;
IntersectPositions2nd(isnan(IntersectPositions2nd))=inf;

%apply the supplied windowing function
IntersectPositionsNx3(~allowedRaysFcnHndl(IntersectPositionsNx3+ones(N,1)*sphereCenter1x3),:)=inf; %We had to add back on the sphereCenter1x3 for windowing purposes since it was taken off at the beginnning
IntersectPositions2nd(~allowedRaysFcnHndl(IntersectPositions2nd+ones(N,1)*sphereCenter1x3),:)=inf; %We had to add back on the sphereCenter1x3 for windowing purposes since it was taken off at the beginnning

%figure out which ones to keep out of multiple solutions
solve1infront = sum((IntersectPositionsNx3-p).*rayDirectionsNx3,2)>0;
solve2infront = sum((IntersectPositions2nd-p).*rayDirectionsNx3,2)>0;
bothinfrontbut2closer=all([solve1infront,solve2infront,sum(abs(IntersectPositionsNx3-p),2) > sum(abs(IntersectPositions2nd-p),2)],2);
onlysolve2infront=all([~solve1infront,solve2infront],2);

IntersectPositionsNx3(all([~solve1infront,~solve2infront],2),:)=inf;
IntersectPositionsNx3(onlysolve2infront,:)=IntersectPositions2nd(onlysolve2infront,:);
IntersectPositionsNx3(bothinfrontbut2closer,:)=IntersectPositions2nd(bothinfrontbut2closer,:);
%End of solve! ...Except for shifting the intersects back out to the actual sphere center


%  check the solves and if any are too far away from the sphere surface, numerically bring them closer (go along the ray direction and add on some distance or take it off) 
    closeness=r-sqrt(sum(IntersectPositionsNx3.^2,2));
    IndicesToGetCloser = all([ abs(closeness)>4e-14 , isfinite(closeness) ],2);
    if any(IndicesToGetCloser)
        %initialize some things
        waytogo=ones(N,1);
        directionchanges=zeros(N,1);
        normedRayDir=s./(sqrt(sum(s.^2,2))*ones(1,3));
    end
    count=1;
    while any(IndicesToGetCloser)
        II=IndicesToGetCloser;%rename
        newIntersectPositionsNx3=((waytogo(II).*closeness(II))*ones(1,3)).*normedRayDir(II,:)+IntersectPositionsNx3(II,:);
        N=size(newIntersectPositionsNx3,1);
        newcloseness=r-sqrt(sum(newIntersectPositionsNx3.^2,2));
        gotSigCloser=abs(newcloseness)<(.8*abs(closeness(II)));%significantly closer means it got more than 20 percent closer than before
        waytogo(II)=waytogo(II).*(ones(N,1)-2*(~gotSigCloser));%go the other direction if you did not get significantly closer
        directionchanges(II)=directionchanges(II)+(~gotSigCloser); %up the direction change tally if it didn't get closer
        II(II)=gotSigCloser; %use this for updating intersects and closeness (the ones that got significantly closer get updated)
        IntersectPositionsNx3(II,:)=newIntersectPositionsNx3(gotSigCloser,:); %if it didn't get significantly closer, then keep the old intersect, otherwise update to the new intersect
        closeness(II)=newcloseness(gotSigCloser); %likewise, keep the old closeness if it didn't get significantly close, otherwise update to the new closeness
        II(II)=abs(newcloseness(gotSigCloser))>4e-14; %only keep updating for those that haven't met this threshold
        GotCloserButStillNotCloseEnough=II;
        IndicesToGetCloser(IndicesToGetCloser)=all([~gotSigCloser,directionchanges(IndicesToGetCloser)<3],2);%IndicesToGetCloser now just has those that didn't getSigCloser but that did turn around
        DidnotgetcloserButTurnedAround=IndicesToGetCloser;
        %now combine the two cases that are good for further iterations in the loop 
        IndicesToGetCloser=logical(GotCloserButStillNotCloseEnough+DidnotgetcloserButTurnedAround);
        
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
%shift IntersectPositionsNx3 back out to where the center of the sphere actually is 
IntersectPositionsNx3=IntersectPositionsNx3+ones(size(rayPositionsNx3,1),1)*sphereCenter1x3;

end







%{


function IntersectPositionsNx3 = RayIntersects_Sphere(rayPositionsNx3,rayDirectionsNx3,sphereCenter1x3,sphereRadius) 
N=size(rayPositionsNx3,1);

d=rayDirectionsNx3;
p=rayPositionsNx3-ones(N,1)*sphereCenter1x3; %shift the ray positions - make the sphere center at the origin
rSqrd=sphereRadius^2;

[~,ind]=max(abs(rayDirectionsNx3),[],2);
ind2=ind==2;
ind3=ind==3;

d(ind2,:)=circshift(d(ind2,:),[0,-1]);
d(ind3,:)=circshift(d(ind3,:),[0,-2]);
p(ind2,:)=circshift(p(ind2,:),[0,-1]);
p(ind3,:)=circshift(p(ind3,:),[0,-2]);


A=sum(d.*d,2);
B=2*d(:,2).*(d(:,1).*p(:,2) - d(:,2).*p(:,1)) + 2*d(:,3).*(d(:,1).*p(:,3) - d(:,3).*p(:,1));
C=(d(:,1).*p(:,2) - d(:,2).*p(:,1)).^2 + (d(:,1).*p(:,3) - d(:,3).*p(:,1)).^2 - d(:,1).^2*rSqrd;

X1=(-B+sqrt(B.^2-4*A.*C))./A/2;
X2=(-B-sqrt(B.^2-4*A.*C))./A/2;
YZ1=d(:,2:3)./[d(:,1),d(:,1)].*([X1(:,1),X1(:,1)]-[p(:,1),p(:,1)])+p(:,2:3);
YZ2=d(:,2:3)./[d(:,1),d(:,1)].*([X2(:,1),X2(:,1)]-[p(:,1),p(:,1)])+p(:,2:3);
clear d
IntersectPositionsNx3=[X1,YZ1];
IntersectPositions2nd=[X2,YZ2];
clear X1 X2 YZ1 YZ2
%Shift indices back to normal
IntersectPositionsNx3(ind2,:)=circshift(IntersectPositionsNx3(ind2,:),[0,1]);
IntersectPositionsNx3(ind3,:)=circshift(IntersectPositionsNx3(ind3,:),[0,2]);
IntersectPositions2nd(ind2,:)=circshift(IntersectPositions2nd(ind2,:),[0,1]);
IntersectPositions2nd(ind3,:)=circshift(IntersectPositions2nd(ind3,:),[0,2]);
p(ind2,:)=circshift(p(ind2,:),[0,1]);
p(ind3,:)=circshift(p(ind3,:),[0,2]);

%clear out imaginary and NaN solutions
IntersectPositionsNx3(imag(IntersectPositionsNx3)~=0)=inf;
IntersectPositions2nd(imag(IntersectPositions2nd)~=0)=inf;
IntersectPositionsNx3(isnan(IntersectPositionsNx3))=inf;
IntersectPositions2nd(isnan(IntersectPositions2nd))=inf;

%figure out which ones to keep out of multiple solutions
solve1infront = sum((IntersectPositionsNx3-p).*rayDirectionsNx3,2)>0;
solve2infront = sum((IntersectPositions2nd-p).*rayDirectionsNx3,2)>0;
bothinfrontbut2closer=all([solve1infront,solve2infront,sum(abs(IntersectPositionsNx3-p),2) > sum(abs(IntersectPositions2nd-p),2)],2);
onlysolve2infront=all([~solve1infront,solve2infront],2);

IntersectPositionsNx3(all([~solve1infront,~solve2infront],2),:)=inf;
IntersectPositionsNx3(onlysolve2infront,:)=IntersectPositions2nd(onlysolve2infront,:);
IntersectPositionsNx3(bothinfrontbut2closer,:)=IntersectPositions2nd(bothinfrontbut2closer,:);

%shift IntersectPositionsNx3 back out to where the center of the sphere actually is 
IntersectPositionsNx3=IntersectPositionsNx3+ones(N,1)*sphereCenter1x3;



%{
%This is code for testing the intersects to verify they are accurate
%Uncomment this section if testing is desired 
disp .
disp **********TESTtheRESULTS_sphere_intersects*******
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
sum((IntersectPositionsNx3-ones(N,1)*sphereCenter1x3).^2,2)-rSqrd     %#ok<NOPRT,MNEFF>
disp ******END_OFTHE_TEST********
end



%}
%}