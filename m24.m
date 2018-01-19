%M2.4)

start=input('what is the start number? '); 
n=input('what is the length? ');
N=start:n;
w=input('what is the angular frequency? where it is (0-pi)only )';
A=input('what is the amplitude? ');
 
phase=input('what is the phase? where it is (0-2pi)only') 
x= A*cos((w*N)+phase);
stem(N,x);
xlabel('Time'); ylabel('Amplitude'); grid on period=2*pi/w; disp(period);


