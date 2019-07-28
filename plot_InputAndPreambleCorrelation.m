function plot_InputAndPreambleCorrelation()
 
 global plots

 CorrelationShortPreamble = plots.CorrelationShortPreamble;
 d = plots.signal;
 PacketCandidates = plots.PacketCandidates;
 
 
    figure('Name','Korrelation','NumberTitle','off');
    hold on;
    plot(1:length(PacketCandidates),PacketCandidates,'r');
    plot((1:length(CorrelationShortPreamble)),CorrelationShortPreamble,'b') % Korrelation im Abstand 16
    axis([-inf inf -0.2 1.2])
    title('Korrelation Short Präambel')
    xlabel('Nummer des Abtastwertes')
    ylabel('Amplitude')
    legend('Paket Kandidaten','Korrelation')
    hold off


    