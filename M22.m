%M2.2)

L = input('Length= ');
N = input('Period = ');  
A = input('Peak Value= '); 
dt= input('Duty Cycle = ');
w = 2*pi/N;
t = 0:w:(L-1)*w;
X = 0:L-1;
sw = A*sawtooth(t); sq = A*square(t,dt);

hold on; subplot(2,1,1) 
stem(X,sw) 
xlabel('Time'); 
ylabel('Amplitude');

subplot(2,1,2), stem(X,sq); xlabel('Time'); ylabel('Amplitude');
