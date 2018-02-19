clf
clearvars
fc='What is your operating frequency';
fc=input(fc);
channelDepth =2000
Numberofsourcepaths =1
BottomLoss=0.5
LossFrequencies=1:1000
VoltageSensitivity=-200
% TxPos='Input matrix in standard MATLAB format such as [50 50 100;50 50 600;50 50 200]: '
% TxPos=[50 50 100;50 50 600;50 50 200]
% xcorr='Please enter the x cordinate of the receiver';
xcorr=0
% ycorr='Please enter the y cordinate of the receiver';
ycorr=0
% zcorr='Please enter the z cordinate of the receiver';
zcorr=0
Speed='What is your propagation speed?';
Speed=1500
forstep=10000
maxdistance=100000
% values=zeros(size(xcorr))
for xcorr=1:forstep:maxdistance
    
    isopath= phased.IsoSpeedUnderwaterPaths(...    %Creates a  channel for the propagation 
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
%     length(TxPos)                                      
%     ValueofA=cell(length(TxPos),1);                                            
%     figure (1)    
%     hold on %   are ignored and not plotted     
%  for k=1:length(TxPos)  %for loop for each point of the transmitter
%   A=TxPos(k,:)    
%   [paths,dop,aloss] = isopath([A(1); A(2); -A(3)],[xcorr;ycorr;-zcorr],... %coordinates for transmitter and reciever,and velocity of transmitter and reciever
%   [0;0;0],[0;0;0],1); 
%   ValueofA{k}=aloss
% %   data=ValueofA{k}
% %   fnm=sprintf('file_%d.csv',k)
% %   save(fnm,'data')       
%   plot(1:Numberofsourcepaths,paths(1,:))
%   xlabel('Path Index')
%   ylabel('Delay Time (s)')                                          
%   end
%     figure (2)
%     clf
%     hold on
%     for k=1:length(TxPos)   %propgation path for each transmitter
%         A=TxPos(k,:)
%         A(1)
%         A(2)
%         A(3)
%         PlotPaths([A(1); A(2); -A(3)],[xcorr;ycorr;-zcorr,],...
%         [channelDepth],[Numberofsourcepaths]);
%     end
%creating a rectanglaur pulse of 1 sec interval with 10ms width
    prf = 1;                 
    pulseWidth = 10e-3;
    pulseBandwidth = 1/pulseWidth;
    fs = 2*pulseBandwidth;
    wav = phased.RectangularWaveform('PRF',prf,'PulseWidth',pulseWidth,...
    'SampleRate',fs);
    channel.SampleRate = fs;

    projector = phased.IsotropicProjector(...                                    %set up the sound projector with frequency range of 0 to 30e3
        'FrequencyRange',[0 1000],'VoltageResponse',250,'BackBaffled',false);
    % figure(20)
    % patternAzimuth(projector,fc);
    [ElementPosition,ElementNormal] = helperSphericalProjector(8,fc,Speed);
    projArray = phased.ConformalArray(...
        'ElementPosition',[ElementPosition],...
        'ElementNormal',[ElementNormal],'Element',projector);

%     figure(23)
%     pattern(projArray,fc,-180:180,0,'CoordinateSystem','polar',...
%         'PropagationSpeed',Speed);
    % figure(56)
    % viewArray(projArray,'ShowNormals',true);

    projRadiator = phased.Radiator('Sensor',projector,...                   %radiates the sound projector signal outwards to the far field
    'PropagationSpeed',Speed,'OperatingFrequency',fc);

    %takes only the last value of the coordinate at the moment
    beaconPlat = phased.Platform('InitialPosition',[0; 0; 0],...   % set a platform for the sound projector
     'Velocity',[0; 0; 0]);

    hydrophone = phased.IsotropicHydrophone('FrequencyRange',[0 1000],...  %set up Hydrophone with the same frequency range as the sound projector and approiate voltage 
     'VoltageSensitivity',VoltageSensitivity);

    array = phased.ULA('Element',hydrophone,...                             %   This object models a ULA formed with identical sensor elements.
    'NumElements',2,'ElementSpacing',Speed/fc/2,...
    'ArrayAxis','x');

    arrayCollector = phased.Collector('Sensor',array,...                    %collects incident narrowband signals from given directions 
    'PropagationSpeed',Speed,'OperatingFrequency',fc);

    arrayPlat= phased.Platform('InitialPosition',[xcorr; ycorr; -zcorr],...
    'Velocity',[0; 0; 0]);

    % rx = phased.ReceiverPreamp(...                                          %Amplifiy weak signals to easier processing
    %     'Gain',20,...
    %     'SampleRate',fs)
    x = wav(); 
    % figure(3);
    % plot(wav); title('Waveform output, real part');
    % xlabel('Samples'); ylabel('Amplitude (V)');                                                %Transmit 10 pings, pings appear as a peak in the received signals
    numTransmits = 10;
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
    figure(4)
    plot(t,rxsig(:,end))
    xlabel('Time (s)');
    ylabel('Signal Amplitude (V)')
%     dboutput=db(rxsig);
%     figure(90)
%     plot(t,dboutput(:,end));
%     xlabel('Time (s)');
%     ylabel('Signal Amplitude (dB)')
    Vpp=peak2peak(rxsig(:,end));
    vdb=20*log10(Vpp);
    Recievelevel=vdb-(VoltageSensitivity);
    table(xcorr,forstep)=Recievelevel;
%     B=table>0;
%     C=table(B);
    tablecor(xcorr,forstep)=xcorr;
%     B1=tablecor>0;
%     C1=tablecor(B1);
    a1=table(table~=0);
    b1=tablecor(tablecor~=0);
%     hold on
%     figure(100)
%     plot(xcorr,C)
end
% hold on;
% plot(C1,C)
figure(5)
plot(b1,a1)
% xcheck=C<50
% Xcheck=xcheck(C)
area(b1(),a1(),'basevalue',0,'Facecolor','r')
% area(b1,a1,'basevalue',190,'FaceColor','g')
% area(A(1:13),B(1:13),'basevalue',0,'FaceColor','g');
xlabel('Distance in x axis(m)')
ylabel('Reciever level(dB)')
'Tool finish'
% area(C1,C,'FaceColor','flat')