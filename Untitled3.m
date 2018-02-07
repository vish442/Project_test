  antenna = phased.IsotropicAntennaElement;
  radiator = phased.Radiator('Sensor',antenna,...
              'OperatingFrequency',300e6);
  x = [1;1];
  radiatingAngle = [30 10]';
  y = radiator(x,radiatingAngle);