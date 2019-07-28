
%% Test Packet mit Alle Rate
dataRate = [ 6 9 12 18 24 36 48 54 ];
frame=[zeros(200,1)];
for i=1:length(dataRate)
    packet=genPacket(dataRate(i),100);
    frame = [frame;packet;zeros(300,1)];
end


