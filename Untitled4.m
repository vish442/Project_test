clf
TxPos=[50 60 70;99 50 1000;100 450 230]
% b=TxPos1(:,end)
% hold on
hold on
for k=1:length(TxPos)
    A=TxPos(k,:)
    A(1)
    A(2)
    A(3)
%     TxPos(1:2)
    PlotPaths([A(1); A(2); -A(3)],[50; 60 ; -70], ...
    5000,5)
end
