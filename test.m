% Example 1:
%   %   Construct an isotropic hydrophone and plot its pattern.  
%   %   Assume the hydrophone operates between 1 and 20 kHz and the
%   %   operating frequency is 10 kHz.



 hydrophone = phased.IsotropicHydrophone('FrequencyRange',[1e3 20e3]);
  fc = 10e3;
  pattern(hydrophone,fc);