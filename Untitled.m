for T=1:50 
platform = phased.Platform([0; 0; 0],[100; 100; 0]);
  
  [pos,v] = platform(T)
  [pos,v] = platform(T)
   Positiontable(:,:,T)=pos;
end