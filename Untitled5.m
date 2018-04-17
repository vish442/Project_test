  projector = phased.IsotropicProjector('VoltageResponse',100);
  fc = 20e3; ang = [0;0];
  resp = projector(fc,ang)