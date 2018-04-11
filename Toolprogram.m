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
LossFrequencies=1:1000000;
VoltageSensitivity=-200;
VoltageResponse=165;   %SOURCE LEVEL
tot_toc=0
h=waitbar(0,'Program is running...');
% tic
% xcorr='Please enter the x cordinate of the receiver';
% xcorr=0;
% ycorr='Please enter the y cordinate of the receiver';
ycorr=1;
% zcorr='Please enter the z cordinate of the receiver';
zcorr=1;
Speed=1500;
forstep=100;
maxdistance=500;
Recievetable=zeros(maxdistance,60);
xdist2=zeros(maxdistance,60);
energytable=zeros(maxdistance,60);
countstep=1;
for xcorr=1:forstep:maxdistance
    
    tic
    isopath= phased.IsoSpeedUnderwaterPaths(...    %Creates a channel for the propagation 
          'ChannelDepth',channelDepth,...
          'NumPathsSource',...                  
          'Property',...                        
          'NumPaths',Numberofsourcepaths,...    
          'PropagationSpeed',Speed,...
          'BottomLoss',BottomLoss,...           
          'TwoWayPropagation',false,...         
          'LossFrequencies',LossFrequencies);   
    channel = phased.MultipathChannel(...
          'OperatingFrequency',fc);                                                

%creating a rectangular pulse of 1 sec interval with 10ms width
    prf = 1;                 
    pulseWidth = 10e-3;
    pulseBandwidth = 1/pulseWidth;
    fs = 2*pulseBandwidth;
    wav = phased.RectangularWaveform('PRF',prf,'PulseWidth',pulseWidth,...
    'SampleRate',fs);
%Update the sample rate of the mulitpath channel with the square waveform
    channel.SampleRate = fs;

    projector = phased.IsotropicProjector(...                                    %set up the sound projector with frequency range of 0 to 30e3
        'FrequencyRange',[1 100000],'VoltageResponse',VoltageResponse,'BackBaffled',false);
    
    [ElementPosition,ElementNormal] = Projectorsetup(3,fc,Speed);
%     projArray = phased.ConformalArray(...
%         'ElementPosition',[0;0;0],...
%         'ElementNormal',[0;0],'Element',projector);
    projArray = phased.ConformalArray(...
        'ElementPosition',ElementPosition,...
        'ElementNormal',ElementNormal,'Element',projector);
    

    projRadiator = phased.Radiator('Sensor',projector,...                   %radiates the sound projector signal outwards to the far field
    'PropagationSpeed',Speed,'OperatingFrequency',fc);

    
    beaconPlat = phased.Platform('InitialPosition',[100000; 100; -5],...   % set a platform for the sound projector
     'Velocity',[0; 0; 0]);

    hydrophone = phased.IsotropicHydrophone('FrequencyRange',[1 100000],...  %set up Hydrophone with the same frequency range as the sound projector and approiate voltage 
     'VoltageSensitivity',VoltageSensitivity);

    array = phased.ULA('Element',hydrophone,...                             %   This object models a ULA formed with identical sensor elements.
    'NumElements',2,'ElementSpacing',Speed/fc/2,...
    'ArrayAxis','x');

    arrayCollector = phased.Collector('Sensor',array,...                    %collects incident narrowband signals from given directions 
    'PropagationSpeed',Speed,'OperatingFrequency',fc);

    arrayPlat= phased.Platform('InitialPosition',[xcorr; ycorr; -zcorr],...
    'Velocity',[0; 0; 0]);

    x = wav(); 
    %Transmit pings, pings appear as a peak in the received signals
    numTransmits = 100;
    rxsig = zeros(size(x,1),2,numTransmits);
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
  
  % Collect the propagated signal
    rsig = arrayCollector(rsig,rcvang);
  
  % Store the received pulses
    rxsig(:,:,i) = abs((rsig));
 
    end
    t = (0:length(x)-1)'/fs;
    clf
%     figure(4)
%     plot(t,rxsig(:,end))
%     xlabel('Time (s)');
%     ylabel('Signal Amplitude (V)')
    Vpp=peak2peak(rxsig(:,end));  % work out the peak to peak values from the signal
    vdb=20*log10(Vpp); %work out the dB of the voltage signal
    energy=trapz(rxsig(:,end));
    Recievelevel=vdb-(VoltageSensitivity); % equation in dB for the voltage sensitivity
    Recievetable(countstep)=Recievelevel;
    xdist2(countstep)=xcorr;
    energytable(countstep)=energy;
    countstep=countstep+1;
    waitbar(xcorr/maxdistance);
%     pause(0.015)
    tot_toc = DisplayEstimatedTimeOfLoop( tot_toc+toc, xcorr, maxdistance-1 )

end
clf
Reducearray=Recievetable(Recievetable~=0 & isfinite(Recievetable));
Reducearrayx=xdist2(xdist2~=0);
Recievetable=Reducearray;
xdist2=Reducearrayx;
if all(Recievetable<0)
    plot(xdist2,Recievetable)
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')
    'Tool finish'
    close(h);
else
    A1=find(Recievetable>60);
    results=Recievetable(A1);
    figure(5)
    hold on
    area(xdist2(1:A1(end)),Recievetable(1:A1(end)),'basevalue',0,'FaceColor','r')
    area(xdist2(A1(end):end),Recievetable(A1(end):end),'basevalue',0,'FaceColor','g')
    ylim([0 VoltageResponse])
    figure(2)
    pattern(projArray,fc,-180:180,0,'CoordinateSystem','polar',...
      'PropagationSpeed',Speed);
    figure(56)
    viewArray(projArray,'ShowNormals',true);
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')
    close(h);
    'Tool finish'
% figure(6)
% plot(1:Numberofsourcepaths,paths(1,:))
%   xlabel('Path Index')
%   ylabel('Delay Time (s)')         
end
end