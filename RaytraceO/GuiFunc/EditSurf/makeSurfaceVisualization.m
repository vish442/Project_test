%This opens up the gui inside of EditSurfMain for surface visualization
function VisSurf_of_SurfO = makeSurfaceVisualization(SurfO,illuminationPoint,symmAxisDir)%this function only needs SurfObj.IntersectSolveFcn to be defined in order to operate, but also uses windows if any are defined
            if isempty(illuminationPoint), illuminationPoint=[1,1,1]; end
            if isempty(symmAxisDir), symmAxisDir=[0,0,1]; end
                
            fh=figure('Name','Surface Visualizer');
            ah=axes('Position',[0.200 0.1100 0.7750 0.8150]);
            axis equal
            offoncellstr={'off','on'};
            
            raycounter=20;
            lineplot3d=1;%initialize
            reducedlineplot3d=2;
            
            
            
            %Use the unzoomed intersect solve to render the surface.  Then
            %when it is displayed (after this function), move it to its zoomed position
            UZIntrsctSolvFull=str2func(SurfO.IntersectSolveGeometryParams{1}); SurfO.IntersectSolveGeometryParams(1)=[];
            unzoomedIntersectSolve=@(rayposNx3,raydirNx3,winFcnHdl)UZIntrsctSolvFull(rayposNx3,raydirNx3,winFcnHdl,SurfO.IntersectSolveGeometryParams{:});
            
            %you also need the unzoomed windowing functions in order to
            %render the surface in its unzoomed state
            %update window solves
            WGCAcounter=1; %WindowGeometryCellArray counter
            WFsCAcounter=1; %WindowFcnsCellArray counter
            WGCA=SurfO.WindowGeometryCellArray;
            UnzoomedWindowFcns=cell(1,length(SurfO.WindowFcnsCellArray));
            while WGCAcounter<=length(SurfO.WindowGeometryCellArray)
                switch lower(WGCA{WGCAcounter})
                    case 'plane' %Expects SurfO.GeometryParametersCellArray{2} to be a plane point 1x3, and SurfO.GeometryParametersCellArray{3} to be a plane surface normal vector 1x3
                        param2=WGCA{WGCAcounter+1};
                        param3=WGCA{WGCAcounter+2};
                        UnzoomedWindowFcns{WFsCAcounter}=@(pointsNx3)WindowingFcn_Plane(pointsNx3,param2,param3);   WGCAcounter=WGCAcounter+3;  WFsCAcounter=WFsCAcounter+1;
                    case 'sphere' %Expects SurfO.GeometryParametersCellArray{2} to be the sphere center point 1x3, and SurfO.GeometryParametersCellArray{3} to be the sphere radius 1x1
                        param2=WGCA{WGCAcounter+2};
                        param3=WGCA{WGCAcounter+3};
                        if strcmpi(WGCA{WGCAcounter+1},'inside'), UnzoomedWindowFcns{WFsCAcounter}=@(pointsNx3)WindowingFcn_Sphere(pointsNx3,param2,param3);
                        else UnzoomedWindowFcns{WFsCAcounter}=@(pointsNx3)WindowingFcn_ExoSphere(pointsNx3,param2,param3); end
                        WGCAcounter=WGCAcounter+4;  WFsCAcounter=WFsCAcounter+1;
                    case 'cylinder' %Expects SurfO.GeometryParametersCellArray{2} to be a cylinder axis point 1x3, and SurfO.GeometryParametersCellArray{3} to be the cylinder axis direction vector 1x3, and SurfO.GeometryParametersCellArray{4} to be the cylinder radius 1x1
                        param2=WGCA{WGCAcounter+2};
                        param3=WGCA{WGCAcounter+3};
                        param4=WGCA{WGCAcounter+4};
                        if strcmpi(WGCA{WGCAcounter+1},'inside'), UnzoomedWindowFcns{WFsCAcounter}=@(pointsNx3)WindowingFcn_Cylinder(pointsNx3,param2,param3,param4);
                        else UnzoomedWindowFcns{WFsCAcounter}=@(pointsNx3)WindowingFcn_ExoCylinder(pointsNx3,param2,param3,param4); end
                        WGCAcounter=WGCAcounter+5;  WFsCAcounter=WFsCAcounter+1;
                    otherwise
                        error('An unidentified window type was encountered')
                end
            end
            
            function PointsAllowedNx1_logical = applyUnzoomedWindowsToPoints(PointsNx3)
                N=size(PointsNx3,1);
                PointsAllowedNx1_logical=true(N,1);
                for n=1:length(UnzoomedWindowFcns)
                    PointsAllowedNx1_logical(PointsAllowedNx1_logical)= UnzoomedWindowFcns{n}(PointsNx3(PointsAllowedNx1_logical,:));
                end
            end
            
            
            
            %decide here if on the first time through you are going to use
            %old parameters for the surface drawing or not
            if isempty(SurfO.OriginalSurfaceXYZstorage)
                nestedfunction();
            else
                VisSurf_of_SurfO=surf(ah,SurfO.OriginalSurfaceXYZstorage{:});
                VisSurf_of_SurfO.Visible='on';
                nestedfunction(1); %the argument allows nargin to be tripped inside the nestedfunction
                helpdlg('The old rendering is displayed. Update it by hitting ''Enter'' inside any of the fields to the left');
                
            end
                
            
            %pick a point to set the illumination on
            %pick an axis of symmetry for the illumination
            %rotate theta = acos(z). phi=atan2(y,x)
            %rotation matrix z = [cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0;0,0,1];
            %rotation matrix about y, going from z to x with pos theta = ;   
            
            function nestedfunction(varargin)
                if nargin<1, hold(ah,'off'); else hold(ah,'on'); end
                
                illthetas= pi/raycounter : pi/raycounter : (pi-pi/raycounter);
                lt=length(illthetas);
                illphis = 0 : pi/raycounter : 2*pi-pi/raycounter;
                lp=length(illphis);
                IllDirections=[repmat([cos(illphis)',sin(illphis)'],[lt,1]),reshape(ones(lp,1)*(tan(illthetas).^(-1)),[lp*lt,1])];
                IllDirections=IllDirections./(sqrt(sum(IllDirections.^2,2))*ones(1,3));
                %At this point the IllDirections are symmetric about the Z axis
                %Now rotate IllDirections to the symmetric axis
                symmAxisDir=symmAxisDir/norm(symmAxisDir);
                thet=acos(symmAxisDir(3));
                phi=atan2(symmAxisDir(2),symmAxisDir(1));
                RMYthet=[cos(thet),0,sin(thet);0,1,0;-sin(thet),0,cos(thet)];
                RMZphi=[cos(phi), -sin(phi), 0; sin(phi), cos(phi), 0;0,0,1];
                IllDirections=(RMZphi*RMYthet*(IllDirections'))';

               
                
                %view the directions, centered about illuminationPoint
                ptsrcView=[reshape([IllDirections(:,1)';zeros(1,lp*lt)],[2*lp*lt,1]),reshape([IllDirections(:,2)';zeros(1,lp*lt)],[2*lp*lt,1]),reshape([IllDirections(:,3)';zeros(1,lp*lt)],[2*lp*lt,1])];
                lineplot3d=plot3(ah,ptsrcView(:,1)+illuminationPoint(1),ptsrcView(:,2)+illuminationPoint(2),ptsrcView(:,3)+illuminationPoint(3),'Marker','.','MarkerSize',15,'MarkerEdgeColor','r');
                lineplot3d.Visible='off';
                xlabel('x')
                ylabel('y')
                zlabel('z')
                axis equal
                %end viewing of directions
                IllIntersects=unzoomedIntersectSolve(ones(lt*lp,1)*illuminationPoint,IllDirections,@(ptset)applyUnzoomedWindowsToPoints(ptset));
                IllDirections(~isfinite(IllIntersects))=inf;%just in case
                
%                 %the following were used to visualize the intersect points. Uncomment to see the intersect points again
%                 hold on
%                 plot3(ah,IllIntersects(:,1),IllIntersects(:,2),IllIntersects(:,3),'Marker','.','MarkerEdgeColor','g','MarkerSize',15,'LineStyle','none');
                 hold on
                
                reducedlineplot3d=plot3(ah,IllDirections(:,1)+illuminationPoint(1),IllDirections(:,2)+illuminationPoint(2),IllDirections(:,3)+illuminationPoint(3),'Marker','.','MarkerSize',35,'MarkerEdgeColor','y','LineStyle','none');
                reducedlineplot3d.Visible='off';
                
%                 %this next line just helped to see in what order the rays were hitting.  Uncomment to see the numbering again   
%                 text(IllDirections(:,1)+illuminationPoint(1),IllDirections(:,2)+illuminationPoint(2),IllDirections(:,3)+illuminationPoint(3),num2str((1:size(IllDirections,1))'));
                
                if nargin<1
                    
                    X=reshape(IllIntersects(:,1),[lp,lt])';
                    Y=reshape(IllIntersects(:,2),[lp,lt])';
                    Z=reshape(IllIntersects(:,3),[lp,lt])';
                    SurfO.OriginalSurfaceXYZstorage={X,Y,Z};
                    VisSurf_of_SurfO=surf(ah,X,Y,Z);
                    set(ah,'XGrid','on','YGrid','on','ZGrid','on')
                    VisSurf_of_SurfO.Visible='on';
                    
                    %establish the COLOR settings using normalized Z elements. 
                    theseuns=isfinite(VisSurf_of_SurfO.ZData);
                    if ~any(any(theseuns)), errordlg('It appears none of the rays from your VisSource are impinging on the surface you''ve defined.  Multiple rays must hit for a visualization to appear.');
                    else
                        minoff=VisSurf_of_SurfO.ZData-min(VisSurf_of_SurfO.ZData(theseuns));
                        if max(minoff(theseuns))-min(minoff(theseuns))<1e-10 %if your surface is in the XY plane, then use the X data for coloration instead of the Z data
                            minoff=VisSurf_of_SurfO.XData-min(VisSurf_of_SurfO.XData(theseuns));
                            SurfO.VisColorData=minoff/max(minoff(theseuns)); %the normalized X data
                        else
                            SurfO.VisColorData=minoff/max(minoff(theseuns)); %else just use the normalized Z data
                        end
                    end
                end
            end
            
            
            xbox=uicontrol(fh,'Style','Edit','Units','normalized','Position',[.02,.9,.1,.05],'String',num2str(illuminationPoint(1)),'Tag','xpos','Callback',{@updateParams});
            uicontrol(fh,'Style','Text','Units','normalized','Position',[.02,.955,.1,.03],'String','x position');
            ybox=uicontrol(fh,'Style','Edit','Units','normalized','Position',[.02,.81,.1,.05],'String',num2str(illuminationPoint(2)),'Tag','ypos','Callback',{@updateParams});
            uicontrol(fh,'Style','Text','Units','normalized','Position',[.02,.865,.1,.03],'String','y position');
            zbox=uicontrol(fh,'Style','Edit','Units','normalized','Position',[.02,.72,.1,.05],'String',num2str(illuminationPoint(3)),'Tag','zpos','Callback',{@updateParams});
            uicontrol(fh,'Style','Text','Units','normalized','Position',[.02,.775,.1,.03],'String','z position');
            
            rmbox=uicontrol(fh,'Style','Edit','Units','normalized','Position',[.02,.62,.1,.05],'String','20','Tag','mult','Callback',{@updateParams});
            uicontrol(fh,'Style','Text','Units','normalized','Position',[.02,.675,.13,.03],'String','ray multiplier');
            
            symmAxisDirBox=uicontrol(fh,'Style','Edit','Units','normalized','Position',[.02,.52,.1,.05],'String',num2str(symmAxisDir),'Tag','ax','Callback',{@updateParams});
            uicontrol(fh,'Style','Text','Units','normalized','Position',[.02,.575,.13,.03],'String','axis choice');
            
            checkill=uicontrol(fh,'Style','Check','Units','normalized','Position',[.02,.42,.17,.05],'String','Show Source','Tag','ax','Callback',{@cicb});
                    function cicb(hobj,~)
                        lineplot3d.Visible=offoncellstr{hobj.Value+1};
                    end
            
            checksrf=uicontrol(fh,'Style','Check','Units','normalized','Position',[.02,.37,.17,.05],'String','Show surface','Tag','ax','Callback',{@cscb},'Value',1);
                    function cscb(hobj,~)
                        VisSurf_of_SurfO.Visible=offoncellstr{hobj.Value+1};                        
                    end
            
            checkredill=uicontrol(fh,'Style','Check','Units','normalized','Position',[.02,.32,.17,.05],'String','HittingRays','Tag','ax','Callback',{@ricb});
                    function ricb(hobj,~)
                        reducedlineplot3d.Visible=offoncellstr{hobj.Value+1};
                    end
            uicontrol(fh,'Style','pushbutton','Units','normalized','Position',[.02,.22,.17,.05],'String','Save & Close','Tag','ax','Callback',@(hobj,evd)delete(fh));
            
            function updateParams(~,~) %this just repeats the first part of the parent function
                hold off
                raycounter=str2double(rmbox.String);
                illuminationPoint=[str2double(xbox.String),str2double(ybox.String),str2double(zbox.String)];
                symmAxisDir=str2num(symmAxisDirBox.String); %#ok<ST2NM>
                nestedfunction();
                lineplot3d.Visible=offoncellstr{checkill.Value+1};
                VisSurf_of_SurfO.Visible=offoncellstr{checksrf.Value+1};
                reducedlineplot3d.Visible=offoncellstr{checkredill.Value+1};
            end
            
            
        end