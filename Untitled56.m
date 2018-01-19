x = wav();    % Generate pulse
xmits = 10;
rx_pulses = zeros(size(x,1),xmits);
t = (0:size(x,1)-1)/fs;

for j = 1:xmits

    % Update target and sonar position
    [sonar_pos,sonar_vel] = plat(1/prf);

    for i = 1:2 %Loop over targets
       [tgt_pos,tgt_vel] = tgtplat{i}(1/prf);

      % Compute transmission paths using the method of images. Paths are
      % updated according to the CoherenceTime property.
      [paths,dop,aloss,tgtAng,srcAng] = isopath{i}(...
            sonar_pos,tgt_pos,...
            sonar_vel,tgt_vel,1/prf);

      % Compute the radiated signals. Steer the array towards the target.
      tsig = radiator(x,srcAng);

      % Propagate radiated signals through the channel.
      tsig = channel{i}(tsig,paths,dop,aloss);

      % Target
      tsig = tgt{i}(tsig,tgtAng);

      % Collector
      rsig = collector(tsig,srcAng);
      rx_pulses(:,j) = rx_pulses(:,j) + ...
               rx(rsig);
    end
end