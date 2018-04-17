c = 1500
fc = 200;
lambda = c/fc;
subarray = phased.ULA(4,0.5*lambda);
array = phased.ReplicatedSubarray('Subarray',subarray,'GridSize',[1 3], ... 
    'SubarraySteering','Phase','PhaseShifterFrequency',fc); 
steer_ang = [0;90]; 
sv_array = phased.SteeringVector('SensorArray',array,... 
    'PropagationSpeed',c,'IncludeElementResponse',false,'NumPhaseShifterBits',5,'EnablePolarization',false); 


wts_array = sv_array(fc,steer_ang);
pattern(array,fc,-90:90,0,'CoordinateSystem','polar',... 
    'Type','directivity','PropagationSpeed',c,'Weights',wts_array,... 
    'SteerAngle',steer_ang);
% legend('phase-shifted subarrays')
 figure(900)
  pattern(array,fc,'CoordinateSystem','polar','Type','directivity');