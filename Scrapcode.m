clf,
clear all
TxPos1=input('Input matrix in standard MATLAB format such as [50 60 70;1000 45 6000]: ')
% TxPos1=[50 60 70 ;1000 50 60]
ndims(TxPos1)
hold on;
b=TxPos1(:,end)
for k=1:length(b)   
   a = plot(0,b(k),'s','MarkerSize',10);
   set(a,'MarkerFaceColor',get(a,'Color'))
end
% for TxPos1
%     plot(TxPos1)
% end
g=TxPos1(1:2)
  hydrophone = phased.IsotropicHydrophone('FrequencyRange',[1e3 20e3]);
  fc = 10e3;
  pattern(hydrophone,fc);