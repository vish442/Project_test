clear all
close all
% theta=0:0.5:2*pi
Distancesurface='What is the distance of the air gun from the water surface ';
Distancesurface= input(Distancesurface)
Frequency='What is the frequency of the airgun ';
Frequency= input(Frequency)
%assume speed is speed of light 
speed=3*10^8;
wavelength=speed/Frequency
Depth ='What is the depth from air gun value? ';
x =input(Depth)
Distance='What is the distance(horizontal) from air gun value? ';
y = input(Distance)
% Amplitude = 'What is the Amplitude from air gun value? ';

isopath{1} = phased.IsoSpeedUnderwaterPaths(...
          'ChannelDepth',channelDepth,...
          'NumPathsSource','Property',...
          'NumPaths',numPaths,...
          'PropagationSpeed',propSpeed,...
          'BottomLoss',0.5,...
          'TwoWayPropagation',true);

% z = input(Amplitude)
C = hypot(x,y)
% D1=surface/cos(theta)
% D2angle=arccos(D1/C)
D2a=(y.^2)./(Distancesurface.^2)
D2=sqrt(D2a.^2)
pathdifference=D2-C
phase=pathdifference*2*pi/wavelength
theta=0:0.1:2*pi
spectral=C+C.*sin(theta+phase)
plot(theta,spectral)












numPaths = 5;
propSpeed = 1520;
channelDepth = 100;

isopath{1} = phased.IsoSpeedUnderwaterPaths(...
          'ChannelDepth',channelDepth,...
          'NumPathsSource','Property',...
          'NumPaths',numPaths,...
          'PropagationSpeed',propSpeed,...
          'BottomLoss',0.5,...
          'TwoWayPropagation',true);

isopath{2} = phased.IsoSpeedUnderwaterPaths(...
          'ChannelDepth',channelDepth,...
          'NumPathsSource','Property',...
          'NumPaths',numPaths,...
          'PropagationSpeed',propSpeed,...
          'BottomLoss',0.5,...
          'TwoWayPropagation',true);
fc = 20e3;   % Operating frequency (Hz)

channel{1} = phased.MultipathChannel(...
          'OperatingFrequency',fc);

channel{2} = phased.MultipathChannel(...
          'OperatingFrequency',fc);      
      
      
      