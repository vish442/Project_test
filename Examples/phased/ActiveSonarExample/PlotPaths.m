function PlotPaths(varargin)
% This function helperPlotPaths is only in support of
% ActiveSonarExample. It may be removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

newplot;

if ischar(varargin{1})
  plotBellhop(varargin{1});
else

   
[TxPos,RxPosAll,ChannelDepth,numPaths] = varargin{1:end};
     validateattributes(TxPos,{'double'},{'2d','nrows',3,'ncols',1});

  validateattributes(RxPosAll,{'double'},{'2d','nrows',3});
  nTargets = size(RxPosAll,2);
   
% Plot source and target locations
hold on
% Source 
% b=TxPos(:,end);
% for k=1:length(b)   
   a = plot(0,TxPos(3),'s','MarkerSize',10);
   set(a,'MarkerFaceColor',get(a,'Color'))
% end

  % Targets
  for nTargets = 1:size(RxPosAll,2)
    TxPos(1:2)
    r = rangeangle([TxPos(1:2); 0],[RxPosAll(1:2,nTargets);0]);
    l = plot(r,RxPosAll(3,nTargets),'o','MarkerSize',10);
    set(l,'MarkerFaceColor',get(l,'Color'))

  end
  
  cm = lines(nTargets+1);
 
  for iTarget = 1:nTargets
    [~,~,~,~,TxPosImage,~]=...
    phased.internal.imageMethod(ChannelDepth,TxPos,RxPosAll(:,iTarget),[0;0;0],numPaths);
    RxPos = RxPosAll(:,iTarget);
       
    % Convert to range
    zS = TxPosImage(3,:);
    zR = RxPos(3);
    r = rangeangle([TxPosImage(1:2,:);zeros(1,numPaths)],[RxPos(1:2);0]);
    r0 = r(1);
    r = r - r0;

    % Plot direct image paths
    line([r0 r(1)],[zR zS(1)],'Color',cm(iTarget+1,:))
    line([r0 r(1)],[zR zS(1)],'Color',cm(iTarget+1,:))
    % Plot Channel interfaces
    linetop = [0 0; r0 0];
    linebot = [0 -ChannelDepth; r0 -ChannelDepth];
    line(linetop(:,1),linetop(:,2),'LineWidth',2);
    line(linebot(:,1),linebot(:,2),'LineWidth',2);

    % Plot direct paths
    slope = @(line) (line(2,2) - line(1,2))/(line(2,1) - line(1,1));
    intercept = @(line) line(1,2) - slope(line)*line(1,1);
    intersectx = @(line1,line2) (intercept(line2)-intercept(line1))/(slope(line1)-slope(line2)); 
    intersecty = @(line1,line2) slope(line1)*(intercept(line2)-intercept(line1))/(slope(line1)-slope(line2)) + intercept(line1);

    % Top first bounces
     for i = 1:ceil((numPaths-1)/2) %2:2+ceil((numPaths-1)/2)-1
        ind = i + 1;
        linei = [r0 zR; r(ind) zS(ind)];
          if mod(i,2)
            line0 = linetop;
           else
            line0 = linebot;
          end

          x0 = intersectx(linei,line0);
          y0 = intersecty(linei,line0);
          line([r0 x0],[zR y0],'Color',cm(iTarget+1,:))

          for j = 1:i-1
            linei = [x0 y0; r(ind-j) zS(ind-j)];
            if isequal(line0,linetop)
              line0 = linebot;
            else
              line0 = linetop;
            end
            line([x0 intersectx(linei,line0)],[y0 intersecty(linei,line0)],'Color',cm(iTarget+1,:));
            x0 = intersectx(linei,line0);
            y0 = intersecty(linei,line0);
          end
          line([r(1) x0],[zS(1) y0],'Color',cm(iTarget+1,:));
     end

     % Bottom first bounces
     for i = 1:floor((numPaths-1)/2) 
        ind = i + ceil((numPaths-1)/2) +1;
        linei = [r0 zR; r(ind) zS(ind)];
          if ~mod(i,2)
            line0 = linetop;
           else
            line0 = linebot;
          end

          x0 = intersectx(linei,line0);
          y0 = intersecty(linei,line0);
          line([r0 x0],[zR y0],'Color',cm(iTarget+1,:))

          for j = 1:i-1
            linei = [x0 y0; r(ind-j) zS(ind-j)];
            if isequal(line0,linetop)
              line0 = linebot;
            else
              line0 = linetop;
            end
            line([x0 intersectx(linei,line0)],[y0 intersecty(linei,line0)],'Color',cm(iTarget+1,:));
            x0 = intersectx(linei,line0);
            y0 = intersecty(linei,line0);
          end
          line([r(1) x0],[zS(1) y0],'Color',cm(iTarget+1,:));
     end
     
  end
xlabel('Range (m)')
  ylabel('Z-position (m)')
  title('Underwater Paths')
  axis tight
%   hold off
  legend('Source','Target1')

  
end

end


