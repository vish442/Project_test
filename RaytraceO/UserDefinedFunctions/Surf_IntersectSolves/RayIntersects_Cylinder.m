% hi
function IntersectPositionsNx3=RayIntersects_Cylinder(rayPositionsNx3,rayDirectionsNx3,allowedRaysFcnHndl,cylAxisPt1x3,cylAxisDir1x3,cylRadius)

N=size(rayPositionsNx3,1);
p=rayPositionsNx3-ones(N,1)*cylAxisPt1x3;
s=rayDirectionsNx3;
dn=cylAxisDir1x3/norm(cylAxisDir1x3);
r=cylRadius;

A=- dn(1)^2*s(:,1).^2 - 2*dn(1)*dn(2)*s(:,1).*s(:,2) - 2*dn(1)*dn(3)*s(:,1).*s(:,3) - dn(2)^2*s(:,2).^2 - 2*dn(2)*dn(3)*s(:,2).*s(:,3) - dn(3)^2*s(:,3).^2 + s(:,1).^2 + s(:,2).^2 + s(:,3).^2;
B=2*p(:,1).*s(:,1) + 2*p(:,2).*s(:,2) + 2*p(:,3).*s(:,3) - 2*dn(1)^2*p(:,1).*s(:,1) - 2*dn(2)^2*p(:,2).*s(:,2) - 2*dn(3)^2*p(:,3).*s(:,3) - 2*dn(1)*dn(2)*p(:,1).*s(:,2) - 2*dn(1)*dn(2)*p(:,2).*s(:,1) - 2*dn(1)*dn(3)*p(:,1).*s(:,3) - 2*dn(1)*dn(3)*p(:,3).*s(:,1) - 2*dn(2)*dn(3)*p(:,2).*s(:,3) - 2*dn(2)*dn(3)*p(:,3).*s(:,2);
C=- dn(1)^2*p(:,1).^2 - 2*dn(1)*dn(2)*p(:,1).*p(:,2) - 2*dn(1)*dn(3)*p(:,1).*p(:,3) - dn(2)^2*p(:,2).^2 - 2*dn(2)*dn(3)*p(:,2).*p(:,3) - dn(3)^2*p(:,3).^2 + p(:,1).^2 + p(:,2).^2 + p(:,3).^2 - r^2;

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
IntersectPositionsNx3(~allowedRaysFcnHndl(IntersectPositionsNx3+ones(N,1)*cylAxisPt1x3),:)=inf; %We had to add back on the cylAxisPt1x3 for windowing purposes since it was taken off at the beginnning
IntersectPositions2nd(~allowedRaysFcnHndl(IntersectPositions2nd+ones(N,1)*cylAxisPt1x3),:)=inf; %We had to add back on the cylAxisPt1x3 for windowing purposes since it was taken off at the beginnning

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
    
    closeness=sqrt(sum(IntersectPositionsNx3.^2,2)-sum((ones(N,1)*dn).*IntersectPositionsNx3,2).^2)-r;   %based on sum(Q.^2)-(sum(Q.*Dn))^2-r^2==0, which defines the cylinder, where Q is a point on the cylinder, Dn is the normalized axis direction, and r is the cyl radius
    
    IndicesToGetCloser = all([ abs(closeness)>4e-14 , isfinite(closeness) ],2);
    if any(IndicesToGetCloser)
        %initialize some things
        waytogo=ones(N,1);
        directionchanges=zeros(N,1);
        normedRayDir=s./(sqrt(sum(s.^2,2))*ones(1,3));
    end
%     %for testing and demonstration
%     figure();plot3([-2;-1;0],[-2;-1;0],[0;0;0],'Marker','x','MarkerSize',20); hold on
%     pause
    count=1;
    while any(IndicesToGetCloser)
        II=IndicesToGetCloser;%rename
        newIntersectPositionsNx3=((waytogo(II).*closeness(II))*ones(1,3)).*normedRayDir(II,:)+IntersectPositionsNx3(II,:);
        N=size(newIntersectPositionsNx3,1);
        newcloseness=sqrt(sum(newIntersectPositionsNx3.^2,2)-sum((ones(N,1)*dn).*newIntersectPositionsNx3,2).^2)-r;
%         %for testing and demonstration
%         plot3([IntersectPositionsNx3(1);newIntersectPositionsNx3(1)],[IntersectPositionsNx3(2);newIntersectPositionsNx3(2)],[IntersectPositionsNx3(3);newIntersectPositionsNx3(3)],'Marker','.','MarkerSize',13);
%         count
%         newcloseness
%         pause
%         
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
IntersectPositionsNx3=IntersectPositionsNx3+ones(size(rayPositionsNx3,1),1)*cylAxisPt1x3;

end


















% Here is the old code
%{
function IntersectPositionsNx3=RayIntersects_Cylinder(rayPositionsNx3,rayDirectionsNx3,cylAxisPt1x3,cylAxisDir1x3,cylRadius)
N=size(rayPositionsNx3,1);
Qn=cylAxisDir1x3'/norm(cylAxisDir1x3);
CylAxPt=cylAxisPt1x3';
rd=rayDirectionsNx3;
rp=rayPositionsNx3;


[~,ind]=max(abs(rayDirectionsNx3),[],2);
ind2=ind==2;
ind3=ind==3;

rd(ind2,:)=circshift(rd(ind2,:),[0,-1]);
rd(ind3,:)=circshift(rd(ind3,:),[0,-2]);
rp(ind2,:)=circshift(rp(ind2,:),[0,-1]);
rp(ind3,:)=circshift(rp(ind3,:),[0,-2]);


A=rd(:,1).^2 + rd(:,2).^2 + rd(:,3).^2 - (Qn(ind).*rd(:,1) + Qn(mod(ind,3)+1).*rd(:,2) + Qn(mod(ind+1,3)+1).*rd(:,3)).^2;
B=2.*(Qn(ind).*rd(:,1) + Qn(mod(ind,3)+1).*rd(:,2) + Qn(mod(ind+1,3)+1).*rd(:,3)).*(Qn(mod(ind,3)+1).*(CylAxPt(mod(ind,3)+1).*rd(:,1) - rd(:,1).*rp(:,2) + rd(:,2).*rp(:,1)) + Qn(mod(ind+1,3)+1).*(CylAxPt(mod(ind+1,3)+1).*rd(:,1) - rd(:,1).*rp(:,3) + rd(:,3).*rp(:,1)) + CylAxPt(ind).*Qn(ind).*rd(:,1)) - 2.*rd(:,2).*(CylAxPt(mod(ind,3)+1).*rd(:,1) - rd(:,1).*rp(:,2) + rd(:,2).*rp(:,1)) - 2.*rd(:,3).*(CylAxPt(mod(ind+1,3)+1).*rd(:,1) - rd(:,1).*rp(:,3) + rd(:,3).*rp(:,1)) - 2.*CylAxPt(ind).*rd(:,1).^2;
C=(CylAxPt(mod(ind,3)+1).*rd(:,1) - rd(:,1).*rp(:,2) + rd(:,2).*rp(:,1)).^2 - (Qn(mod(ind,3)+1).*(CylAxPt(mod(ind,3)+1).*rd(:,1) - rd(:,1).*rp(:,2) + rd(:,2).*rp(:,1)) + Qn(mod(ind+1,3)+1).*(CylAxPt(mod(ind+1,3)+1).*rd(:,1) - rd(:,1).*rp(:,3) + rd(:,3).*rp(:,1)) + CylAxPt(ind).*Qn(ind).*rd(:,1)).^2 + (CylAxPt(mod(ind+1,3)+1).*rd(:,1) - rd(:,1).*rp(:,3) + rd(:,3).*rp(:,1)).^2 + CylAxPt(ind).^2.*rd(:,1).^2 - rd(:,1).^2*cylRadius^2;

X1=(-B+sqrt(B.^2-4*A.*C))./A/2;
X2=(-B-sqrt(B.^2-4*A.*C))./A/2;
YZ1=rd(:,2:3)./[rd(:,1),rd(:,1)].*([X1(:,1),X1(:,1)]-[rp(:,1),rp(:,1)])+rp(:,2:3);
YZ2=rd(:,2:3)./[rd(:,1),rd(:,1)].*([X2(:,1),X2(:,1)]-[rp(:,1),rp(:,1)])+rp(:,2:3);
clear rd rp
IntersectPositionsNx3=[X1,YZ1];
IntersectPositions2nd=[X2,YZ2];
clear X1 X2 YZ1 YZ2
%Shift indices back to normal
IntersectPositionsNx3(ind2,:)=circshift(IntersectPositionsNx3(ind2,:),[0,1]);
IntersectPositionsNx3(ind3,:)=circshift(IntersectPositionsNx3(ind3,:),[0,2]);
IntersectPositions2nd(ind2,:)=circshift(IntersectPositions2nd(ind2,:),[0,1]);
IntersectPositions2nd(ind3,:)=circshift(IntersectPositions2nd(ind3,:),[0,2]);

%clear out imaginary and NaN solutions
IntersectPositionsNx3(imag(IntersectPositionsNx3)~=0)=inf;
IntersectPositions2nd(imag(IntersectPositions2nd)~=0)=inf;
IntersectPositionsNx3(isnan(IntersectPositionsNx3))=inf;
IntersectPositions2nd(isnan(IntersectPositions2nd))=inf;

solve1infront = sum((IntersectPositionsNx3-rayPositionsNx3).*rayDirectionsNx3,2)>0;
solve2infront = sum((IntersectPositions2nd-rayPositionsNx3).*rayDirectionsNx3,2)>0;
bothinfrontbut2closer=all([solve1infront,solve2infront,sum(abs(IntersectPositionsNx3-rayPositionsNx3),2) > sum(abs(IntersectPositions2nd-rayPositionsNx3),2)],2);
onlysolve2infront=all([~solve1infront,solve2infront],2);

IntersectPositionsNx3(all([~solve1infront,~solve2infront],2),:)=inf;
IntersectPositionsNx3(onlysolve2infront,:)=IntersectPositions2nd(onlysolve2infront,:);
IntersectPositionsNx3(bothinfrontbut2closer,:)=IntersectPositions2nd(bothinfrontbut2closer,:);




%{
%This is code for testing the intersects to verify they are accurate
%Uncomment this section if testing is desired 
disp .
disp **********TESTtheRESULTS_CylinderIntersect*******
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

temp=[sum((IntersectPositionsNx3-ones(N,1)*CylAxPt').^2,2),cylRadius^2+sum((IntersectPositionsNx3-ones(N,1)*CylAxPt').*(ones(N,1)*Qn'),2).^2];
disp('This should also be smaaaaaallllll'); temp(~isfinite(temp))=0;
test=sum(sum(abs(diff( temp,1,2 ))))/N;
disp(test) %this should be small
if test>1e-10
    disp('These should be the same down each column')
    disp(temp)
else
    disp('All the intersect positions seem valid')
end
disp ******END_OFTHE_TEST********

end
%}
%}