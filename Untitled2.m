%ray tracing seismic reflection for horizontal layer earth model 

clear; clc 
for z=1:3 
lap=[1:3]; 
nolayers=lap(z); 
norays=3; %untuk setting theta di bawah, hati-hati dengan jumlah rays terhadap critical angle!!! 
vel=[1500,1800]; %velocity in each layer
dz=[300,500,];%klayer thickness

for i=1:norays 
theta(i)=i*2.2; %shotting angle
end 

for k=1:norays 
for i=1:nolayers-1 
theta(i+1,k)=(180/pi) * asin(sin(theta(i,k).*pi/180).*(vel(i+1)./vel(i))); 
end 
end 
for k=1:norays 
p(k)=sin(theta(1,k).*pi/180)./vel(1);
end 

for k=1:norays 
for i=1:nolayers 
dx(i,k)=(p(k)*vel(i).*dz(i))/sqrt(1-p(k)*p(k).*vel(i).*vel(i));
dt(i,k)=dz(i)/(vel(i).*sqrt(1-p(k)*p(k).*vel(i).*vel(i)));
end 
end 

for k=1:norays 
twt(k)=2*sum(dt(:,k)); 
end 

%%%Offset Manipulation
dx_down=dx; 
dx_up=flipud(dx_down); 
dx=[dx_down;dx_up]; 
dx(1,1)=dx(1,1); 
for k=1:norays 
for i=2:nolayers*2, 
dx(i,k)=dx(i-1,k)+dx(i,k); 
end 
end 
nol=[1:norays]*0; 
dx=[nol;dx]; 

%%Depth manipulation
dz=dz(1:nolayers); 
dz(1)=dz(1); 
for i=2:nolayers, 
dz(i)=dz(i-1)+dz(i); 
end 
dz_down=dz'; 
dz_up=flipud(dz_down); 
dz_up=dz_up(2:nolayers); 
dz=[0;dz_down;dz_up;0]; 
offset=dx(nolayers*2+1,:); 

% plot 
for k=1:norays 
subplot(1,2,1) 
plot(dx(:,k),dz); hold on 
end 
xlabel('offset(m)') 
ylabel('depth(m)') 
title('Jejak Sinar') 
state=set(gca,'ydir'); 
if (strcmp(state,'reverse')) 
set(gca,'ydir','reverse') 
else 
set(gca,'ydir','reverse') 
end 

a=size(dx); 
dx=reshape(dx,a(1,1)*a(1,2),1); 
x = [0 max(dx)]; 
for i=1:nolayers 
y = [dz(i) dz(i)]; 
plot(x,y,'r'); hold on 
end 
axis([0 max(dx) 0 max(dz)]); 
subplot(1,2,2) 
plot(offset,twt,'linewidth',3); grid on; hold on 
xlabel('offset(m)') 
ylabel('twt(s)') 
title('Kurva Waktu Tempuh') 
state=set(gca,'ydir'); 
if (strcmp(state,'reverse')) 
set(gca,'ydir','reverse') 
else 
set(gca,'ydir','reverse') 
end 
clear 
end