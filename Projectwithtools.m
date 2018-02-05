clf
clearvars
fc='What is your operating frequency';
fc=input(fc);
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
Speed='What is your propagation speed?';
Speed=input(Speed);
isopath = phased.IsoSpeedUnderwaterPaths(...    %Creates a  channel for the propagation 
          'ChannelDepth',channelDepth,...
          'NumPathsSource',...                  %
          'Property',...                        %   Property where the default is 'Auto'. When you set this
          'NumPaths',Numberofsourcepaths,...    %   property to 'Auto', the object automatically determines the
          'PropagationSpeed',Speed,...
          'BottomLoss',BottomLoss,...           %   you set this property to 'Property', the number of paths is
          'TwoWayPropagation',false,...         %   specified via the NumPaths property
          'LossFrequencies',LossFrequencies);   %   number of paths based on spreading and reflection losses. When
 channel = phased.MultipathChannel(...
          'OperatingFrequency',fc);                                                
    length(TxPos)                                      
    ValueofA=cell(length(TxPos),1);                                            
    figure (1)    
    hold on %   are ignored and not plotted     
 for k=1:length(TxPos)  %for loop for each point of the transmitter
  A=TxPos(k,:)    
  [paths,dop,aloss] = isopath([A(1); A(2); -A(3)],[xcorr;ycorr;-zcorr],... %coordinates for transmitter and reciever,and velocity of transmitter and reciever
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
%creating a rectanglaur pulse of 1 sec interval with 10ms width
prf = 1;                 
pulseWidth = 10e-3;
pulseBandwidth = 1/pulseWidth;
fs = 2*pulseBandwidth;
wav = phased.RectangularWaveform('PRF',prf,'PulseWidth',pulseWidth,...
  'SampleRate',fs);
channel.SampleRate = fs;
x = wav();
figure(3);
plot(wav); title('Waveform output, real part');
xlabel('Samples'); ylabel('Amplitude (V)');

projector = phased.IsotropicProjector(...                                    %set up the sound projector with frequency range of 0 to 30e3
    'FrequencyRange',[0 30e3],'VoltageResponse',80,'BackBaffled',false);

projRadiator = phased.Radiator('Sensor',projector,...                   %radiates the sound projector signal outwards to the far field
  'PropagationSpeed',Speed,'OperatingFrequency',fc);

ProjectorPlatform = phased.Platform('InitialPosition',[A(1); A(2); -A(3)],...   % set a platform for the sound projector
  'Velocity',[0; 0; 0]);

hydrophone = phased.IsotropicHydrophone('VoltageSensitivity',-150);
array = phased.ULA('Element',hydrophone,...
  'NumElements',2,'ElementSpacing',Speed/fc/2,...
  'ArrayAxis','y');

arrayCollector = phased.Collector('Sensor',array,...
  'PropagationSpeed',Speed,'OperatingFrequency',fc);

HydrophonePlatform = phased.Platform('InitialPosition',[xcorr; ycorr; -xcorr],...
  'Velocity',[0; 0; 0]);

rx = phased.ReceiverPreamp(...
    'Gain',20,...
    'SampleRate',fs)

x = wav();                                                  %Transmit 10 pings, pings appear as a peak in the received signals
numTransmits = 10;
rxsig = zeros(size(x,1),5,numTransmits);
for i = 1:numTransmits

  % Update array and acoustic beacon positions
  [pos_tx,vel_tx] = ProjectorPlatform(1/prf);
  [pos_rx,vel_rx] = HydrophonePlatform (1/prf);

  % Compute paths between the acoustic beacon and array
  [paths,dop,aloss,rcvang,srcang] = ...
      isopath(pos_tx,pos_rx,vel_tx,vel_rx,1/prf);

  % Propagate the acoustic beacon waveform
  tsig = projRadiator(x,srcang);
  rsig = channel(tsig,paths,dop,aloss);

  % Collect the propagated signal
  rsig = arrayCollector(rsig,rcvang);

  % Store the received pulses
  rxsig(:,:,i) = abs(rx(rsig));

end
figure(4)
t = (0:length(x)-1)'/fs;
plot(t,rxsig(:,end))
xlabel('Time (s)');
ylabel('Signal Amplitude (V)')


