clf
clearvars
n = input('Enter a number: ');
switch n
    case 1
fc='What is your operating frequency';
fc=input(fc);
channelDepth=10;
Numberofsourcepaths =1;
BottomLoss=0.5;
TVR=140%db
voltagerms=60
VoltageResponse=TVR+voltagerms ; %SOURCE LEVEL
LossFrequencies=1:1000000;
VoltageSensitivity=-200;
% VoltageResponse=100;   
redzone=40
tot_toc=0
% tic
% xcorr='Please enter the x cordinate of the receiver';
% xcorr=0;
% ycorr='Please enter the y cordinate of the receiver';
ycorr=1;
% zcorr='Please enter the z cordinate of the receiver';
zcorr=1;
Speed=1500;
landa=Speed/fc;
forstep=100;
maxdistance=300;
Recievetable=zeros(maxdistance,60);
xdist2=zeros(maxdistance,60);
energytable=zeros(maxdistance,60);
pressuretable=zeros(maxdistance,60);
time=zeros(10000,1);
countstep=1; 
    isopath= phased.IsoSpeedUnderwaterPaths(...    %Creates a channel for the propagation 
          'ChannelDepth',channelDepth,...
          'NumPathsSource',...                  
          'Property',...                        
          'NumPaths',Numberofsourcepaths,...    
          'PropagationSpeed',Speed,...
          'BottomLoss',BottomLoss,...           
          'TwoWayPropagation',false,...         
          'LossFrequencies',LossFrequencies);   
    channel = phased.MultipathChannel(...           % Calculates the losses due to propagation
          'OperatingFrequency',fc);                                                

%creating a rectangular pulse of 1 sec interval with 10ms width
    prf = 1;                 
    pulseWidth = 10e-3;
    pulseBandwidth = 1/pulseWidth;
%   PRF                   - Pulse repetition frequency
    fs = 2*pulseBandwidth;
    wav = phased.RectangularWaveform('PRF',prf,'PulseWidth',pulseWidth,...
    'SampleRate',fs);
%Update the sample rate of the mulitpath channel with the square waveform
    channel.SampleRate = fs;

    %set up the sound projector with frequency range of 0 to 30e3
    projector = phased.IsotropicProjector(...                                    
        'FrequencyRange',[1 100000],'VoltageResponse',VoltageResponse,'BackBaffled',false);
    
%     [ElementPosition,ElementNormal] = Projectorsetup(3,fc,Speed,projector);
    arrayrect=phased.URA('Element',projector,...
 'Size',[2,2],...
 'ElementSpacing',[landa/2 landa/2],...
 'ArrayNormal','z',...
 'Taper',1)
% Phas=90   
% sPa= phased.ReplicatedSubarray('Subarray',arrayrect,...
%  'Layout','Rectangular',...
%  'GridSize',[2,2],...
%  'GridSpacing','Auto',...
%  'SubarrayNormal',[0 -90;0 -90],...
%  'SubarraySteering',90,...
%  'PhaseShifterFrequency',fc,...
%  'NumPhaseShifterBits',180)
% % Phas=sPa.SubarraySteering


%radiates the sound projector signal outwards to the far field
    projRadiator = phased.Radiator('Sensor',arrayrect,...                   
    'PropagationSpeed',Speed,'OperatingFrequency',fc,'CombineRadiatedSignals',true);
% projRadiator.steervec
    % set a platform for the sound projector
    beaconPlat = phased.Platform('InitialPosition',[10; 10; -5],...   
     'Velocity',[0; 0; 0]);
 
%set up Hydrophone with the same frequency range as the sound projector and approiate voltage 
    hydrophone = phased.IsotropicHydrophone('FrequencyRange',[1 100000],...  
     'VoltageSensitivity',VoltageSensitivity);

 %   This object models a ULA formed with identical sensor elements.
%     array = phased.ULA('Element',hydrophone,...                             
%     'NumElements',1,'ElementSpacing',Speed/fc/2,...
%     'ArrayAxis','z');


%collects incident narrowband signals from given directions 
    arrayCollector = phased.Collector('Sensor',hydrophone,...                 
    'PropagationSpeed',Speed,'OperatingFrequency',fc);




h=waitbar(0,'Program is running...');

% for ycorr=1:forstep:maxdistance
for xcorr=1:forstep:maxdistance
     tic
    arrayPlat= phased.Platform('InitialPosition',[xcorr; ycorr; -zcorr],...
    'Velocity',[0; 0; 0]);

    x = wav(); 
    
    
    %Transmit pings, pings appear as a peak in the received signals
    numTransmits = 10;
    rxsig = zeros(size(x,1),1,numTransmits);
    for i = 1:numTransmits

    % Update array and acoustic beacon positions
    [pos_tx,vel_tx] = beaconPlat(1/prf);
    [pos_rx,vel_rx] = arrayPlat(1/prf);

    % Compute paths between the acoustic beacon and array
    [paths,dop,aloss,rcvang,srcang] = ...
         isopath(pos_tx,pos_rx,vel_tx,vel_rx,1/prf);

  % Propagate the acoustic beacon waveform
    tsig = projRadiator(x,srcang);
     rsig = channel(tsig,paths,dop,aloss);
  
%      beamformer=phased.PhaseShiftBeamformer('SensorArray',arrayrect,...
%     'OperatingFrequency',fc,'PropagationSpeed',Speed,...
%     'DirectionSource','Property','WeightsOutputPort',true);
% [rsig,w]=beamformer(rsig)
  % Collect the propagated signal
    rsig = arrayCollector(rsig,rcvang);
  
  % Store the received pulses making all voltage values as DC by using
  % abosoultes
    rxsig(:,:,i) = abs((rsig));
 
    end
    t = (0:length(x)-1)'/fs;
    clf
    figure(4)
    plot(t,rxsig(:,end))
    xlabel('Time (s)');
    ylabel('Signal Amplitude (V)')
    Vpp=peak2peak(rxsig(:,end));  % work out the peak to peak values from the signal
    vdb=20*log10(Vpp); %work out the dB of the voltage signal
    energy=trapz(t,rxsig(:,end));
    Recievelevel=vdb-(VoltageSensitivity); % equation in dB for the voltage sensitivity
    Recievetable(countstep)=Recievelevel; % populate array with values
    xdist2(countstep)=xcorr;
    energytable(countstep)=energy;
    countstep=countstep+1;              %Indexing the array 
    waitbar(xcorr/maxdistance);
    pressure=10^(Recievelevel/20)*1e-6;
    pressuretable(countstep)=pressure;
%     timefinder=find(rxsig(:,end)>0);
%     timedist=t(timefinder);
%     time1=timedist(3);
%     time2=timedist(1);
%     recordtime=time1-time2;
%     time(countstep)=t;
%     pause(0.015)
    tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, xcorr, maxdistance-1 )

end
end
clf
Reducearray=Recievetable(Recievetable~=0 & isfinite(Recievetable));
Reducearrayx=xdist2(xdist2~=0);
xdist2=Reducearrayx;
% y=flipud(Reducearray);
y=Reducearray*1;
A1=find(y>redzone);
TF=isempty(A1)
x=all(Reducearray<0)& TF==1;
FindA1=find(A1==0);
if (all(Reducearray<0)&& TF==1)
    figure(3)
    plot(xdist2,y)
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')
    'Tool finish'
    close(h);
elseif TF==1
    figure(2)
    plot(xdist2,y)
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')
    'Tool finish'
    close(h);
else
    
    results=y(A1);
    figure(5)
    hold on
    area(xdist2(1:A1(end)),y(1:A1(end)),'basevalue',0,'FaceColor','r')
    area(xdist2(A1(end):end),y(A1(end):end),'basevalue',0,'FaceColor','g')
    ylim([0 VoltageResponse])
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')
    figure(2)
    pattern(sPa,fc,-180:180,-90,'CoordinateSystem','polar',...
      'PropagationSpeed',Speed);
  figure(900)
  pattern(arrayrect,fc,'CoordinateSystem','polar','Type','directivity');
%     figure(56)
%     viewArray(sPa,'ShowNormals',true);
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')
    close(h);
    'Tool finish'
% figure(6)
% plot(1:Numberofsourcepaths,paths(1,:))
%   xlabel('Path Index')
%   ylabel('Delay Time (s)')         
end
% end
