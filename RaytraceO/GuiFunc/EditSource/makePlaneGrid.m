function [Xcol,Ycol,Zcol]=makePlaneGrid(plotaxs)
if nargin==0
    figure('NumberTitle','off','Name','Grid View');
    plotaxs=axes();
end
%%
plt3=plot3(plotaxs,1,1,1,'LineStyle','none','Marker','.','MarkerSize',15);
axis(plotaxs,'equal')

controlsfig=figure('NumberTitle','off','Name','Make Grid','MenuBar','none');
uicontrol(controlsfig,'Style','text','String','Grid centerpoint','Units','Normalized','Position',[.1,.95,.2,.03],'Units','pixels');
CP=uicontrol(controlsfig,'Style','edit','String','1 1 1','Units','Normalized','Position',[.1,.9,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

uicontrol(controlsfig,'Style','text','String','Normal vector to plane of grid','Units','Normalized','Position',[.1,.85,.2,.03],'Units','pixels');
NV=uicontrol(controlsfig,'Style','edit','String','1 1 1','Units','Normalized','Position',[.1,.8,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

AspcLbl=uicontrol(controlsfig,'Style','text','String','Axis A spacing','Units','Normalized','Position',[.1,.75,.2,.03],'Units','pixels');
Aspc=uicontrol(controlsfig,'Style','edit','String','1','Units','Normalized','Position',[.1,.7,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

BspcLbl=uicontrol(controlsfig,'Style','text','String','Axis B spacing','Units','Normalized','Position',[.1,.65,.2,.03],'Units','pixels');
Bspc=uicontrol(controlsfig,'Style','edit','String','1','Units','Normalized','Position',[.1,.6,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

ActLbl=uicontrol(controlsfig,'Style','text','String','Count A','Units','Normalized','Position',[.1,.55,.2,.03],'Units','pixels');
Act=uicontrol(controlsfig,'Style','edit','String','2','Units','Normalized','Position',[.1,.5,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

BctLbl=uicontrol(controlsfig,'Style','text','String','Count B','Units','Normalized','Position',[.1,.45,.2,.03],'Units','pixels');
Bct=uicontrol(controlsfig,'Style','edit','String','2','Units','Normalized','Position',[.1,.4,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

bg=uibuttongroup(controlsfig,'Position',[.1,.3,.3,.05],'Units','pixels','SelectionChangedFcn',@(objh,evd)makeAnddispgrid());
uicontrol(bg,'Style','radio','String','Rectangle','Units','Normalized','Position',[0 0 .5 1]);
uicontrol(bg,'Style','radio','String','Ellipse','Units','Normalized','Position',[.5 0 1 1]);


DTHR=uicontrol(controlsfig,'Style','check','String','Dithered','Units','Normalized','Position',[.1,.2,.2,.05],'Value',0,'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());
 
uicontrol(controlsfig,'Style','text','String','Rotation amount','Units','Normalized','Position',[.1,.15,.2,.03],'Units','pixels');
ROT=uicontrol(controlsfig,'Style','edit','String','0','Units','Normalized','Position',[.1,.1,.2,.05],'Units','pixels','Callback',@(objh,evd)makeAnddispgrid());

RING=uicontrol(controlsfig,'Style','check','String','Make ring','Units','Normalized','Position',[.1,.03,.2,.05],'Units','pixels','Callback',@(objh,evd)changeui(objh));

controlsfig.Position=[440   378   230   420];

uiwait(controlsfig)

delete(plt3)

%%

    function makeAnddispgrid()
        if RING.Value==1
            makeringpts()
        else
        
        centerpoint=str2num(CP.String);%#ok<ST2NM>
        surfacenormal=str2num(NV.String);%#ok<ST2NM>
        Aspacing=str2double(Aspc.String);
        Bspacing=str2double(Bspc.String);
        SemiAcount=str2double(Act.String);
        SemiBcount=str2double(Bct.String);
        ellipseorrectangle=bg.SelectedObject.String;
        dithered=DTHR.Value;
        rotation=str2double(ROT.String);



        surfacenormal=surfacenormal/sqrt(sum(surfacenormal.^2));
        horzvec=cross(surfacenormal,[0 0 1]);
        horzveclength=sqrt(sum(horzvec.^2));
        if horzveclength>1e-9
            horzvec=horzvec/horzveclength;
        else
            horzvec=[1,0,0];
        end
        Vvec=cross(horzvec,surfacenormal); Vvec=Vvec/sqrt(sum(Vvec.^2));

        gspine=ones(2*SemiAcount+1,1)*centerpoint+Aspacing*((-SemiAcount:SemiAcount)')*Vvec; %A is spaced along the Vvec direction 
        Xv=gspine(:,1)*ones(1,2*SemiBcount+1);%h and v stand for horizontal and vertical.  Horizontal should only have XY directionality
        Yv=gspine(:,2)*ones(1,2*SemiBcount+1);
        Zv=gspine(:,3)*ones(1,2*SemiBcount+1);

        crossbar=(horzvec')*Bspacing*(-SemiBcount:SemiBcount); %B is spaced along the horzvec direction
        Xh=ones(2*SemiAcount+1,1)*crossbar(1,:);
        Yh=ones(2*SemiAcount+1,1)*crossbar(2,:);
        Zh=ones(2*SemiAcount+1,1)*crossbar(3,:);

        X=Xv+Xh;
        Y=Yv+Yh;
        Z=Zv+Zh;

        if dithered
            AwanderAmts=(rand(2*SemiAcount+1,2*SemiBcount+1)-.5);
            BwanderAmts=(rand(2*SemiAcount+1,2*SemiBcount+1)-.5);

            Awandervecs=AwanderAmts(:)*Vvec*Aspacing;
            Bwandervecs=BwanderAmts(:)*horzvec*Bspacing;

            Xcol=Awandervecs(:,1)+Bwandervecs(:,1)+X(:);
            Ycol=Awandervecs(:,2)+Bwandervecs(:,2)+Y(:);
            Zcol=Awandervecs(:,3)+Bwandervecs(:,3)+Z(:);
        else
            Xcol=X(:);
            Ycol=Y(:);
            Zcol=Z(:);
        end


        if strcmpi(ellipseorrectangle,'ellipse')
            %keep only those in the ellipse
            %x^2/A^2+y^2/B^2<=1
            dotPtsVvec=sum([Xcol-centerpoint(1),Ycol-centerpoint(2),Zcol-centerpoint(3)].*(ones((2*SemiAcount+1)*(2*SemiBcount+1),1)*Vvec),2);
            dotPtsHorzvec=sum([Xcol-centerpoint(1),Ycol-centerpoint(2),Zcol-centerpoint(3)].*(ones((2*SemiAcount+1)*(2*SemiBcount+1),1)*horzvec),2);
            removethese=dotPtsVvec.^2/(SemiAcount*Aspacing)^2+dotPtsHorzvec.^2/(SemiBcount*Bspacing)^2>1;
            Xcol(removethese)=[];
            Ycol(removethese)=[];
            Zcol(removethese)=[];
        end

        if rotation~=0
            envZm=1; %OmC just becomes an array rather than a function here - OmC is a function in other places where this code is copied from
            a=centerpoint(1);b=centerpoint(2);c=centerpoint(3);u=surfacenormal(1);v=surfacenormal(2);w=surfacenormal(3);thet=rotation;OmC=1-cos(thet);
            rotatn=[u^2+(v^2+w^2)*cos(thet),     u*v*OmC(envZm)-w*sin(thet),      u*w*OmC(envZm)+v*sin(thet),   (a*(v^2+w^2)-u*(b*v+c*w))*OmC(envZm)+(b*w-c*v)*sin(thet);...
                u*v*OmC(envZm)+w*sin(thet),     v^2+(u^2+w^2)*cos(thet),     v*w*OmC(envZm)-u*sin(thet),   (b*(u^2+w^2)-v*(a*u+c*w))*OmC(envZm)+(c*u-a*w)*sin(thet); ...
                u*w*OmC(envZm)-v*sin(thet),     v*w*OmC(envZm)+u*sin(thet),        w^2+(u^2+v^2)*cos(thet),   (c*(u^2+v^2)-w*(a*u+b*v))*OmC(envZm)+(a*v-b*u)*sin(thet);...
                0,0,0,1];
            rotated=(rotatn*([Xcol,Ycol,Zcol,ones(length(Zcol),1)]'))';
            Xcol=rotated(:,1);
            Ycol=rotated(:,2);
            Zcol=rotated(:,3);
        end

        plt3.XData=Xcol;
        plt3.YData=Ycol;
        plt3.ZData=Zcol;
        % =plot3(plotaxs,Xcol,Ycol,Zcol,'LineStyle','none','Marker','.','MarkerSize',15)
        % get(plt3)
        % xlabel(plotaxs,'x');
        % ylabel(plotaxs,'y');
        % zlabel(plotaxs,'z');
        end

    end


    function changeui(checkboxh)
        if checkboxh.Value==1
            Bct.Enable='off';
            BctLbl.String='';
            BspcLbl.String='Semi-Axis B length';
            AspcLbl.String='Semi-Axis A length';
            ActLbl.String='Ring Count';
            bg.Visible='off';
            DTHR.Enable='off';
            makeringpts();
        else
            Bct.Enable='on';
            BctLbl.String='Count B';
            BspcLbl.String='Axis B Spacing';
            AspcLbl.String='Axis A Spacing';
            ActLbl.String='Count A';
            bg.Visible='on';
            DTHR.Enable='on';
            makeAnddispgrid();
        end
    end

    function makeringpts()
            centerpoint=str2num(CP.String);%#ok<ST2NM>
            surfacenormal=str2num(NV.String);%#ok<ST2NM>
            SemiAlength=str2double(Aspc.String);
            SemiBlength=str2double(Bspc.String);
            RingCount=str2double(Act.String);
            rotation=str2double(ROT.String);
            thetarray=0:2*pi/RingCount:(2*pi-2*pi/RingCount);

            surfacenormal=surfacenormal/sqrt(sum(surfacenormal.^2));
            horzvec=cross(surfacenormal,[0 0 1]);
            horzveclength=sqrt(sum(horzvec.^2));
            if horzveclength>1e-9
                horzvec=horzvec/horzveclength;
            else
                horzvec=[1,0,0];
            end
            Vvec=cross(horzvec,surfacenormal); Vvec=Vvec/sqrt(sum(Vvec.^2));

            allpts=ones(length(thetarray),1)*centerpoint + SemiBlength*cos(thetarray)'*horzvec + SemiAlength*sin(thetarray)'*Vvec;
            Xcol=allpts(:,1);
            Ycol=allpts(:,2);
            Zcol=allpts(:,3);

            if rotation~=0
                envZm=1;
                a=centerpoint(1);b=centerpoint(2);c=centerpoint(3);u=surfacenormal(1);v=surfacenormal(2);w=surfacenormal(3);thet=rotation;OmC=1-cos(thet);
                rotatn=[u^2+(v^2+w^2)*cos(thet),     u*v*OmC(envZm)-w*sin(thet),      u*w*OmC(envZm)+v*sin(thet),   (a*(v^2+w^2)-u*(b*v+c*w))*OmC(envZm)+(b*w-c*v)*sin(thet);...
                    u*v*OmC(envZm)+w*sin(thet),     v^2+(u^2+w^2)*cos(thet),     v*w*OmC(envZm)-u*sin(thet),   (b*(u^2+w^2)-v*(a*u+c*w))*OmC(envZm)+(c*u-a*w)*sin(thet); ...
                    u*w*OmC(envZm)-v*sin(thet),     v*w*OmC(envZm)+u*sin(thet),        w^2+(u^2+v^2)*cos(thet),   (c*(u^2+v^2)-w*(a*u+b*v))*OmC(envZm)+(a*v-b*u)*sin(thet);...
                    0,0,0,1];
                rotated=(rotatn*([Xcol,Ycol,Zcol,ones(length(Zcol),1)]'))';
                Xcol=rotated(:,1);
                Ycol=rotated(:,2);
                Zcol=rotated(:,3);
            end
            
            plt3.XData=Xcol;
            plt3.YData=Ycol;
            plt3.ZData=Zcol;

    end


end


