clf
fc='What is your operating frequency';
fc=input(fc);
% TxPos=[50 60 70;99 50 1000;100 450 230]
channelDepth ='What is the depth from the surface to the bottom of the ocean? ';
channelDepth =input(channelDepth);
Numberofsourcepaths ='How many number of source paths do you wish to have? ';
Numberofsourcepaths =input(Numberofsourcepaths);
BottomLoss='What is the loss in dB for the bottom surface reflection?';
BottomLoss=input(BottomLoss);
LossFrequencies='In Hertz what is is your absorption loss?';
LossFrequencies=input(LossFrequencies);
TxPos='Input matrix in standard MATLAB format such as [50 60 70;1000 45 6000;400 500 200]: '
TxPos=input(TxPos)
xcorr='Please enter the x cordinate of the receiver';
xcorr=input(xcorr);
ycorr='Please enter the y cordinate of the receiver';
ycorr=input(ycorr);
zcorr='Please enter the z cordinate of the receiver';
zcorr=input(zcorr);

Speed=1 %m/s propgation speed
isopath{1} = phased.IsoSpeedUnderwaterPaths(...
          'ChannelDepth',channelDepth,...
          'NumPathsSource',...                  %
          'Property',...                        %   Property where the default is 'Auto'. When you set this
          'NumPaths',Numberofsourcepaths,...    %   property to 'Auto', the object automatically determines the
          'PropagationSpeed',Speed,...
          'BottomLoss',BottomLoss,...           %   you set this property to 'Property', the number of paths is
          'TwoWayPropagation',false,...         %   specified via the NumPaths property
          'LossFrequencies',LossFrequencies);   %   number of paths based on spreading and reflection losses. When
 channel{1} = phased.MultipathChannel(...
          'OperatingFrequency',fc);                                                
    length(TxPos)                                      
    ValueofA=cell(length(TxPos),1);                                            
    figure (1)    
    hold on %   are ignored and not plotted     
 for k=1:length(TxPos)  %for loop for each point of the transmitter
  A=TxPos(k,:)    
  [paths,dop,aloss] = isopath{1}([A(1); A(2); -A(3)],[xcorr;ycorr;-zcorr],... %coordinates for transmitter and reciever,and velocity of transmitter and reciever
  [0;0;0],[0;0;0],1); 
  ValueofA{k}=aloss
%   data=ValueofA{k}
%   fnm=sprintf('file_%d.csv',k)
%   save(fnm,'data')       
  plot(1:Numberofsourcepaths,paths(1,:))
  xlabel('Path Index')
  ylabel('Delay Time (s)')                                          
  end
figure (2)
clf
hold on
for k=1:length(TxPos)   %propgation path for each transmitter
    A=TxPos(k,:)
    A(1)
    A(2)
    A(3)
    PlotPaths([A(1); A(2); -A(3)],[xcorr;ycorr;-zcorr,],...
    [channelDepth],[Numberofsourcepaths]);
end

proj = phased.IsotropicProjector(...
    'FrequencyRange',[0 30e3],'VoltageResponse',80,'BackBaffled',false);
N=length(TxPos) % number of elements in series
projArray = phased.ConformalArray(...
    'ElementPosition',ElementPosition,...
    'ElementNormal',ElementNormal,'Element',proj);

figure (3)
viewArray(projArray,'ShowNormals',true);
pattern(projArray,fc,-180:180,0,'CoordinateSystem','polar','Type','powerdb',...
      'PropagationSpeed',Speed);
  a=4