figure;

% plot(1:length(packet),real(packet),'r');
% plot(1:length(packet),imag(packet),'b');
plot(1:length(packet),real(packet),'b');
xlabel('Sample [t.f_t]');
ylabel('Re\{Packet\}');
hold on;
line([0 320],[0.2 0.2],'Color','r','LineWidth',2);
line([320 320],[0.24 0],'Color','r','LineStyle','--')
text(10,0.23,'Präambel');

line([321 481],[0.2 0.2],'Color','r','LineWidth',2);
line([481 481],[0.24 0],'Color','r','LineStyle','--')
text(340,0.23,'Signal-Feld');

line([482 length(packet)],[0.2 0.2],'Color','r','LineWidth',2);
line([length(packet) length(packet)],[0.24 0],'Color','r','LineStyle','--')
text(500,0.23,'Daten-Feld');

