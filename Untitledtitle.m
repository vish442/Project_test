results=y(A1);
    figure(5453)
    hold on
    title(['Reciever Level against distance at ' num2str(fc) 'Hz  '])
    area(xdist2(1:A1(end)),y(1:A1(end)),'basevalue',0,'FaceColor','r')
    area(xdist2(A1(end):end),y(A1(end):end),'basevalue',0,'FaceColor','g')
    ylim([0 VoltageResponse])
    xlabel('Distance in x axis(m)')
    ylabel('Reciever level(dB)')