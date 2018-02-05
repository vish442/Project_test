% n=10; % number of lines
% a= inputdlg('enter x coordinates','test',n)
% x=str2num(a{1})
% b= inputdlg('enter y coordinates','test',n)
% y=str2num(b{1})
% c= inputdlg('enter z coordinates','test',n)
% z=str2num(c{1})
prf = 5;                                                                %creating a rectanglaur pulse of 1 sec interval with 10ms width
pulseWidth = 10e-3;
pulseBandwidth = 1/pulseWidth;
fs = 2*pulseBandwidth;
wav = phased.RectangularWaveform('PRF',prf,'PulseWidth',pulseWidth,...
  'SampleRate',fs);
channel.SampleRate = fs;
x = wav();
plot(real(x)); title('Waveform output, real part');
xlabel('Samples'); ylabel('Amplitude (V)');
