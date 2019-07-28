function [packet,dataBitsCrc]=genPacket(Mbps,Bytes)

[p, ref] = generate_preamble;

[data_sym,dataBitsCrc] = txData(Mbps,Bytes);
bytes = length(dataBitsCrc)/8;
signal_sym  = txSignal(Mbps,bytes);


data_sym=data_sym(:);
packet = [p(1:end-1);signal_sym; data_sym];


%%add noise
% Pnoise = -94.797;
% numSamples = length(packet);
% nSignal = wgn(1, numSamples, Pnoise, 'dbm', 'complex') .* sqrt(2);
% packet = packet + nSignal';

% if nargin>2
% figure;
% 
% % plot(1:length(packet),real(packet),'r');
% % plot(1:length(packet),imag(packet),'b');
% plot(1:length(packet),real(packet),'b');
% xlabel('Zeit [t.f_t]');
% ylabel('Re\{Packet\}');
% hold on;
% line([0 320],[0.2 0.2],'Color','r','LineWidth',2);
% text(10,0.3,'Präambel');
% 
% line([321 160],[0.2 0.2],'Color','r','LineWidth',2);
% text(p(end-1)+1+10,0.3,'Signal-Feld');
% 
% line([481 length(data_sym)],[0.2 0.2],'Color','r','LineWidth',2);
% text(p(end-1)+1+signal_sym(end)+10,0.3,'Daten-Feld');
% 
% 
% end
