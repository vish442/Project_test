maxRange = 5000;                         % Maximum unambiguous range
rangeRes = 10;                           % Required range resolution
prf = Speed/(2*maxRange);                % Pulse repetition frequency
pulse_width = 2*rangeRes/Speed;          % Pulse width
pulse_bw = 1/pulse_width;                % Pulse bandwidth
fs = 2*pulse_bw;                         % Sampling rate
wav = phased.RectangularWaveform(...
    'PulseWidth',pulse_width,...
    'PRF',prf,...
    'SampleRate',fs);
TxPos=[50 60 70;99 50 1000;100 450 230]
plat = phased.Platform(...
    'InitialPosition',[0; 0; -100],...
    'Velocity',[0; 0; 0]);

proj = phased.IsotropicProjector(...
    'FrequencyRange',[0 100],'VoltageResponse',80,'BackBaffled',false);
fc=100
% N=length(TxPos) % number of elements in series
N=4

% [ElementPosition,ElementNormal] = helperSphericalProjector(N,fc,Speed);
xpos = [1 0 0 1];
ypos = [0 100 -1 60];
zpos = [0 -4000 1000 1];
ElementNormalx= [0 0 0 0]
ElementNormaly= [0 0 0 0]
projArray = phased.ConformalArray(...
    'ElementPosition',[xpos; ypos; zpos],...
    'ElementNormal',[ElementNormalx;ElementNormaly] ,'Element',proj);
figure (3)
viewArray(projArray,'ShowNormals',true);

pattern(projArray,fc,-180:180,0,'CoordinateSystem','polar',...
      'PropagationSpeed',Speed);
