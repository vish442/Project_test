


function IntersectPositionsNx3 = RayIntersects_ParabaloidSymmetric(rayPositionsNx3,rayDirectionsNx3,allowedRaysFcnHndl,vertex1x3,focus1x3)

N=size(rayPositionsNx3,1);
p=rayPositionsNx3-ones(N,1)*focus1x3;
s=rayDirectionsNx3;
D=focus1x3-vertex1x3;
dn=D/norm(D);
twoMagD=2*norm(D);

%This is the main part of the solve.  This solves for the distance the ray
%must travel in order to intersect the parabola. We calculate here the A, B
%and C portions of the quadratic equation.
    A=- dn(1)^2*s(:,1).^2 - 2*dn(1)*dn(2)*s(:,1).*s(:,2) - 2*dn(1)*dn(3)*s(:,1).*s(:,3) - dn(2)^2*s(:,2).^2 - 2*dn(2)*dn(3)*s(:,2).*s(:,3) - dn(3)^2*s(:,3).^2 + s(:,1).^2 + s(:,2).^2 + s(:,3).^2;
    B=(2*p(:,1).*s(:,1) + 2*p(:,2).*s(:,2) + 2*p(:,3).*s(:,3) - 2*dn(1)^2*p(:,1).*s(:,1) - 2*dn(2)^2*p(:,2).*s(:,2) - 2*dn(3)^2*p(:,3).*s(:,3) - 2*dn(1)*s(:,1)*twoMagD - 2*dn(2)*s(:,2)*twoMagD - 2*dn(3)*s(:,3)*twoMagD - 2*dn(1)*dn(2)*p(:,1).*s(:,2) - 2*dn(1)*dn(2)*p(:,2).*s(:,1) - 2*dn(1)*dn(3)*p(:,1).*s(:,3) - 2*dn(1)*dn(3)*p(:,3).*s(:,1) - 2*dn(2)*dn(3)*p(:,2).*s(:,3) - 2*dn(2)*dn(3)*p(:,3).*s(:,2));
    C= - dn(1)^2*p(:,1).^2 - 2*dn(1)*dn(2)*p(:,1).*p(:,2) - 2*dn(1)*dn(3)*p(:,1).*p(:,3) - 2*dn(1)*p(:,1)*twoMagD - dn(2)^2*p(:,2).^2 - 2*dn(2)*dn(3)*p(:,2).*p(:,3) - 2*dn(2)*p(:,2)*twoMagD - dn(3)^2*p(:,3).^2 - 2*dn(3)*p(:,3)*twoMagD + p(:,1).^2 + p(:,2).^2 + p(:,3).^2 - twoMagD^2;

    distance1=(-B+sqrt(B.^2-4*A.*C))./A/2;
    distance2=(-B-sqrt(B.^2-4*A.*C))./A/2;
    specials=A<1e-8;  %sometimes rays produce small A values - when rays are parallel to the vertex-focus - this is bad for computation, so we do this
    distance1(specials)=-C(specials)./B(specials); %special adjustment for parabolic solve
    distance2(specials)=inf; %special adjustment for parabolic solve
    IntersectPositionsNx3=p+(distance1*ones(1,3)).*s;
    IntersectPositions2nd=p+(distance2*ones(1,3)).*s;

    %clear out imaginary and NaN solutions
    IntersectPositionsNx3(imag(IntersectPositionsNx3)~=0)=inf;
    IntersectPositions2nd(imag(IntersectPositions2nd)~=0)=inf;
    IntersectPositionsNx3(isnan(IntersectPositionsNx3))=inf;
    IntersectPositions2nd(isnan(IntersectPositions2nd))=inf;
    
    %apply the supplied windowing function
    IntersectPositionsNx3(~allowedRaysFcnHndl(IntersectPositionsNx3+ones(N,1)*focus1x3),:)=inf;
    IntersectPositions2nd(~allowedRaysFcnHndl(IntersectPositions2nd+ones(N,1)*focus1x3),:)=inf;

    %figure out which ones to keep out of multiple solutions
    solve1infront = sum((IntersectPositionsNx3-p).*s,2)>0;
    solve2infront = sum((IntersectPositions2nd-p).*s,2)>0;
    bothinfrontbut2closer=all([solve1infront,solve2infront,sum(abs(IntersectPositionsNx3-p),2) > sum(abs(IntersectPositions2nd-p),2)],2);
    onlysolve2infront=all([~solve1infront,solve2infront],2);

    IntersectPositionsNx3(all([~solve1infront,~solve2infront],2),:)=inf;
    IntersectPositionsNx3(onlysolve2infront,:)=IntersectPositions2nd(onlysolve2infront,:);
    IntersectPositionsNx3(bothinfrontbut2closer,:)=IntersectPositions2nd(bothinfrontbut2closer,:);
    %End of the solve!
    
  
    %now check the solves and if any are too far away from the parabola, numerically bring them closer (go along the ray direction and add on some distance or take it off) 
    
    %get the right closeness factor
    dydx=sqrt(sum(IntersectPositionsNx3.^2,2)-sum(IntersectPositionsNx3.*(ones(N,1)*dn),2).^2)/twoMagD;
    closenessscalefactor=1/2+2*atan(dydx)/pi;
    closeness=closenessscalefactor.*(sqrt(sum(IntersectPositionsNx3.^2,2))- sum(IntersectPositionsNx3.*(ones(N,1)*dn),2)-twoMagD);
    
    %figure out which indices need to get closer
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
        newcloseness=closenessscalefactor(II).*(sqrt(sum(newIntersectPositionsNx3.^2,2)) - sum(newIntersectPositionsNx3.*(ones(N,1)*dn),2)-twoMagD);
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
    
    

cm=abs(closeness(isfinite(closeness)))>4e-14; %report any non-close rays
if sum(cm)>1
    disp([num2str(sum(cm)),' rays fell short of optimal surface closeness'])
    disp([num2str(count),' iterations were used in attempting to reduce closeness']);
end

%add back on the shift that was taken off at the beginning (shifted the focus to the origin) 
IntersectPositionsNx3(:,1)=IntersectPositionsNx3(:,1)+focus1x3(1);
IntersectPositionsNx3(:,2)=IntersectPositionsNx3(:,2)+focus1x3(2);
IntersectPositionsNx3(:,3)=IntersectPositionsNx3(:,3)+focus1x3(3);



% this was inside the "if sum(cm)>1" statement for visualizing which points
% were having trouble intersecting correctly
%     closeness(cm)
%     hold on
%     plot3(IntersectPositionsNx3(cm,1),IntersectPositionsNx3(cm,2),IntersectPositionsNx3(cm,3),'Marker','.','MarkerSize',20)



%   %for testing purposes  
%         disp(['Iterations of numerical solve: ',num2str(count)])
%         disp('The max of closeness/(distance ray traveled):')
%         [m,II]=max(closeness./(sum((p-IntersectPositionsNx3).^2,2).^(1/2)));
%         disp(m)
%         disp('The closeness:')
%         disp(closeness(II))
%         disp('The distance:')
%         disp(sum((p(II,:)-IntersectPositionsNx3(II,:)).^2,2).^(1/2))

end













%  Here follows the old code that was not as good at calculating
%  intersects.  It tried to directly solve for the X component of the
%  intersect and then substitute back for the Y and Z values.  The code was
%  complex and convoluted and still failed to produce good intersects when
%  the vertex-focus vector and the incident ray vector were roughly
%  parallel.

%{
function IntersectPositionsNx3 = RayIntersects_ParabaloidSymmetric(rayPositionsNx3,rayDirectionsNx3,vertex1x3,focus1x3) 

FmV=(focus1x3-vertex1x3)';
aSqrd=sum(FmV.*FmV);
v=vertex1x3';
rd=rayDirectionsNx3;
rp=rayPositionsNx3;

[~,ind]=max(abs(rayDirectionsNx3),[],2);
ind2=ind==2;
ind3=ind==3;

rd(ind2,:)=circshift(rd(ind2,:),[0,-1]);
rd(ind3,:)=circshift(rd(ind3,:),[0,-2]);
rp(ind2,:)=circshift(rp(ind2,:),[0,-1]);
rp(ind3,:)=circshift(rp(ind3,:),[0,-2]);
% FmV(ind2,:)=circshift(FmV(ind2,:),[0,-1]);
% FmV(ind3,:)=circshift(FmV(ind3,:),[0,-2]);
% v(ind2,:)=circshift(v(ind2,:),[0,-1]);
% v(ind3,:)=circshift(v(ind3,:),[0,-2]);


A=rd(:,1).^2 - (rd(:,1).*FmV(ind) + rd(:,2).*FmV(mod(ind,3)+1) + rd(:,3).*FmV(mod(ind+1,3)+1)).^2/aSqrd + rd(:,2).^2 + rd(:,3).^2;
B=(2*(rd(:,1).*FmV(ind) + rd(:,2).*FmV(mod(ind,3)+1) + rd(:,3).*FmV(mod(ind+1,3)+1)).*(FmV(mod(ind,3)+1).*(rd(:,1).*v(mod(ind,3)+1) + rp(:,1).*rd(:,2) - rp(:,2).*rd(:,1)) + FmV(mod(ind+1,3)+1).*(rd(:,1).*v(mod(ind+1,3)+1) + rp(:,1).*rd(:,3) - rp(:,3).*rd(:,1)) + rd(:,1).*v(ind).*FmV(ind)))/aSqrd - 4*rd(:,1).^2.*FmV(ind) - 2*rd(:,2).*(rd(:,1).*v(mod(ind,3)+1) + rp(:,1).*rd(:,2) - rp(:,2).*rd(:,1)) - 2*rd(:,3).*(rd(:,1).*v(mod(ind+1,3)+1) + rp(:,1).*rd(:,3) - rp(:,3).*rd(:,1)) - 4*rd(:,1).*rd(:,2).*FmV(mod(ind,3)+1) - 4*rd(:,1).*rd(:,3).*FmV(mod(ind+1,3)+1) - 2*rd(:,1).^2.*v(ind);
C=4*FmV(mod(ind,3)+1).*(rd(:,1).^2.*v(mod(ind,3)+1) - rp(:,2).*rd(:,1).^2 + rp(:,1).*rd(:,1).*rd(:,2)) + 4*FmV(mod(ind+1,3)+1).*(rd(:,1).^2.*v(mod(ind+1,3)+1) - rp(:,3).*rd(:,1).^2 + rp(:,1).*rd(:,1).*rd(:,3)) - (FmV(mod(ind,3)+1).*(rd(:,1).*v(mod(ind,3)+1) + rp(:,1).*rd(:,2) - rp(:,2).*rd(:,1)) + FmV(mod(ind+1,3)+1).*(rd(:,1).*v(mod(ind+1,3)+1) + rp(:,1).*rd(:,3) - rp(:,3).*rd(:,1)) + rd(:,1).*v(ind).*FmV(ind)).^2/aSqrd + (rd(:,1).*v(mod(ind,3)+1) + rp(:,1).*rd(:,2) - rp(:,2).*rd(:,1)).^2 + (rd(:,1).*v(mod(ind+1,3)+1) + rp(:,1).*rd(:,3) - rp(:,3).*rd(:,1)).^2 + rd(:,1).^2.*v(ind).^2 + 4*rd(:,1).^2.*v(ind).*FmV(ind);

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

%figure out which ones to keep out of multiple solutions
solve1infront = sum((IntersectPositionsNx3-rayPositionsNx3).*rayDirectionsNx3,2)>0;
solve2infront = sum((IntersectPositions2nd-rayPositionsNx3).*rayDirectionsNx3,2)>0;
bothinfrontbut2closer=all([solve1infront,solve2infront,sum(abs(IntersectPositionsNx3-rayPositionsNx3),2) > sum(abs(IntersectPositions2nd-rayPositionsNx3),2)],2);
onlysolve2infront=all([~solve1infront,solve2infront],2);

IntersectPositionsNx3(all([~solve1infront,~solve2infront],2),:)=inf;
IntersectPositionsNx3(onlysolve2infront,:)=IntersectPositions2nd(onlysolve2infront,:);
IntersectPositionsNx3(bothinfrontbut2closer,:)=IntersectPositions2nd(bothinfrontbut2closer,:);
%End of the solve!


p=rayPositionsNx3;
s=rayDirectionsNx3;
N=size(p,1);
D=focus1x3-vertex1x3;
dn=D/norm(D);
f=focus1x3;
twoMagD=2*norm(D);
closeness=sqrt(sum((IntersectPositionsNx3-ones(N,1)*f).^2,2))- sum((IntersectPositionsNx3-ones(N,1)*f).*(ones(N,1)*dn),2)-twoMagD;
    IndicesToGetCloser=closeness>9e-14;
    if any(IndicesToGetCloser)
        %initialize some things
        dotsign=sum(s.*(ones(N,1)*D),2);
        normedRayDir=s./(sqrt(sum(s.^2,2))*ones(1,3));
    end
    count=1;
    while any(IndicesToGetCloser)
        II=IndicesToGetCloser;%rename
        IntersectPositionsNx3(II,:)=((dotsign(II).*closeness(II))*ones(1,3)).*normedRayDir(II,:)+IntersectPositionsNx3(II,:);
        closeness=sqrt(sum((IntersectPositionsNx3-ones(N,1)*f).^2,2))- sum((IntersectPositionsNx3-ones(N,1)*f).*(ones(N,1)*dn),2)-twoMagD;
        IndicesToGetCloser=closeness>9e-14;
        count=count+1;
        if count>14
            disp('The max of closeness/(distance ray traveled):')
            disp(max(closeness(IndicesToGetCloser)./(sum((p(IndicesToGetCloser,:)-IntersectPositionsNx3(IndicesToGetCloser,:)).^2,2).^(1/2))))
            break;
        end
    end

%{
%This is code for testing the intersects to verify they are accurate
%Uncomment this section if testing is desired
disp .
disp **********TESTtheRESULTS_parabola_intersect*******
disp .
%test the results
successss=true;
rd=rayDirectionsNx3;
rd(abs(rd)<1e-10)=nan;
ip=IntersectPositionsNx3;
ip(~isfinite(ip))=nan;
N=size(rayPositionsNx3,1);
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
    successss=false;
end

%test that they are on the parabola
thet=acos(sum((ip-ones(N,1)*vertex1x3).*( ones(N,1)*FmV' ),2)/ sqrt(sum(FmV.^2))./sqrt(sum((ip-ones(N,1)*vertex1x3).^2,2)));
temp=[sqrt(sum((ip-ones(N,1)*vertex1x3).^2,2)).*sin(thet),4*sqrt(sum((focus1x3-vertex1x3).^2,2))./tan(thet)];
rowsoffparab=diff(temp,1,2)>1e-9;
if any(rowsoffparab)
    rpo=rayPositionsNx3(rowsoffparab,:);
    rdo=rayDirectionsNx3(rowsoffparab,:);
    rio=IntersectPositionsNx3(rowsoffparab,:);
    disp('Here is one ray that went off the paraboloid:')
    disp('The starting ray position:');
    disp(rpo(1,:));
    disp('The starting ray direction:');
    disp(rdo(1,:));
    disp('The intersect point');
    disp(rio(1,:));
    successss=false;
end

if successss
    disp('TESTS PASSED SUCCESSFULLY')
end

%}

end


%}

