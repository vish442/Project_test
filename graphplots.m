% plot(b1,a1)
hold on
A1=find(a1>20)
results=a1(A1)
area(b1(1:A1(end)),a1(1:A1(end)),'basevalue',0,'FaceColor','r')
area(b1(A1(end):end),a1(A1(end):end),'basevalue',0,'FaceColor','g')
% ylim([0 VoltageResponse])