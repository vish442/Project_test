clf
clearvars
fc='What is your operating frequency';
fc=input(fc);
channelDepth=2000;
Numberofsourcepaths =1
BottomLoss=0.5;
LossFrequencies=1:100000;
VoltageSensitivity=-200
VoltageResponse=150
% xcorr='Please enter the x cordinate of the receiver';
xcorr=0
% ycorr='Please enter the y cordinate of the receiver';
ycorr=0
% zcorr='Please enter the z cordinate of the receiver';
zcorr=0
Speed=1500
forstep=5000
maxdistance=300000
table=zeros(300000,6000);
tablecor=zeros(300000,6000);
for xcorr=1:forstep:maxdistance
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

%creating a rectanglaur pulse of 1 sec interval with 10ms width
    prf = 1;                 
    pulseWidth = 10e-3;
    pulseBandwidth = 1/pulseWidth;
    fs = 2*pulseBandwidth;
    wav = phased.RectangularWaveform('PRF',prf,'PulseWidth',pulseWidth,...
    'SampleRate',fs);
    channel.SampleRate = fs;

    projector = phased.IsotropicProjector(...                                    %set up the sound projector with frequency range of 0 to 30e3
        'FrequencyRange',[1 100000],'VoltageResponse',VoltageResponse,'BackBaffled',false);
    
%     [ElementPosition,ElementNormal] = helperSphericalProjector(8,fc,Speed);
    projArray = phased.ConformalArray(...
        'ElementPosition',[0;0;0],...
        'ElementNormal',[0;0],'Element',projector);

    projRadiator = phased.Radiator('Sensor',projector,...                   %radiates the sound projector signal outwards to the far field
    'PropagationSpeed',Speed,'OperatingFrequency',fc);

    
    beaconPlat = phased.Platform('InitialPosition',[0; 0; 0],...   % set a platform for the sound projector
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
    %Transmit 10 pings, pings appear as a peak in the received signals
    numTransmits = 200;
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
    figure(4)
    plot(t,rxsig(:,end))
    xlabel('Time (s)');
    ylabel('Signal Amplitude (V)')
    Vpp=peak2peak(rxsig(:,end));  % work out the peak to peak values from the signal
    vdb=20*log10(Vpp); %work out the dB of the voltage signal
    Recievelevel=vdb-(VoltageSensitivity); % equation in dB for the voltage sensitivity
    table(xcorr,forstep)=Recievelevel;
    tablecor(xcorr,forstep)=xcorr;
%     pathstable(xcorr,forstep)=paths(3)
end

a1=table(table~=0);
b1=tablecor(tablecor~=0);
clf
A1=find(a1>60);
results=a1(A1);
figure(5)
hold on
area(b1(1:A1(end)),a1(1:A1(end)),'basevalue',0,'FaceColor','r')
area(b1(A1(end):end),a1(A1(end):end),'basevalue',0,'FaceColor','g')
% ylim([0 VoltageResponse])
% ref=10000:forstep:500000;
% Int1=spline(b1,a1,ref);
% Int2=pchip(b1,a1,ref)
% g=fnxtr(a1)
% plot(ref,Int1)
% % vq1=interp1(b1,a1,ref)
% ylim([0 VoltageResponse])

% plot(P2)
% plot(b1,P1)
% figure(56)
%     viewArray(projArray,'ShowNormals',true);
xlabel('Distance in x axis(m)')
ylabel('Reciever level(dB)')
'Tool finish'
