fc = 300e6;
c = physconst('LightSpeed');
array = phased.ULA('NumElements',4);
steervec = phased.SteeringVector('SensorArray',array);
sv = steervec(fc,[30;20]);


subplot(211)
pattern(array,fc,-180:180,0,'CoordinateSystem','rectangular', ...
    'PropagationSpeed',c,'Type','powerdb')
title('Without steering')
subplot(212)
pattern(array,fc,-180:180,0,'CoordinateSystem','rectangular', ...
    'PropagationSpeed',c,'Type','powerdb','Weights',sv)
title('With steering')