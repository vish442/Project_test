  % Example 2:
  %   Simulates the trajectory of an object for 15 seconds. The object
  %   starts from the origin and has an acceleration of [1;0;0] m/s^2.
  
  platform = phased.Platform('MotionModel','Acceleration',...
          'Acceleration',[1;0;0]);
  dt = 1;  N = 15;  t = (0:N-1)*dt;
  pos = zeros(3,N); vel = zeros(3,N);

  for m = 1:N
      [pos(:,m), vel(:,m)] = platform(dt);0
  end

  ax = plotyy(t,pos(1,:),t,vel(1,:)); xlabel(ax(1),'Time (s)');
  ylabel(ax(1),'Position (m)'); ylabel(ax(2),'Velocity (m/s)');