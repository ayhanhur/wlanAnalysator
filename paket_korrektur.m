function [Packet,LongPreambleStart]= paket_korrektur (signal,PacketPositions)

% Paket korrigieren , symbolpositionschätzen
% Longpreamble lokalisieren
% Frequenzversatz korrigieren

global MinimumPacketSize
global WindowCoarseCFO
global WindowFineCFO
global ft
global PeriodLongPreamble
global PeriodShortPreamble

global plots

for k=1:length(PacketPositions)
    
    Packet{k} = signal(PacketPositions(k):end);  % Cut out single Packets
    % Jedes Paket ist dann mindestens 1000 lang für Algorithmen
    Packet{k} = [ Packet{k} ; zeros(max(MinimumPacketSize,MinimumPacketSize-length(Packet{k})),1) ]; 
    t = (1:length(Packet{k}))/ft; 
    
    %% Coarse Estimation of center Frequency
    CoarseCFO = EstimateCoarseCFO(Packet{k},ft,WindowCoarseCFO,PeriodShortPreamble); 
    Packet{k} = Packet{k}.*exp(j*2*pi*(t')*(-CoarseCFO)); % And imideate Correction of CFO 
    
    %% Fine Estimation of center Frequency
    FineCFO   = EstimateFineCFO(Packet{k},ft,PeriodLongPreamble,WindowFineCFO);
    Packet{k} = Packet{k}.*exp(j*2*pi*(t')*(-FineCFO));  % And imideate Correction of CFO;

    %% Symbolposition schätzen
    LongPreambleStart(k)= estimate_LP1(Packet{k});
    
%     %% Paket Korrelation Kanaleinflüsse
%     
%     snap = Packet{k}(GuardInterval+LongPreambleStart(k)+(0:SymbolLength-1));
%     h1   = fftshift(fft(snap)).*ref(:,3);
%     snap = Packet{k}(GuardInterval+SymbolLength+LongPreambleStart(k)+(0:SymbolLength-1));
%     h2   = fftshift(fft(snap)).*ref(:,3);
%     %korrelation
%     KOR = 1./((h1+h2)*0.5);
%     KOR(find(abs(KOR)>1e15)) = 0;
%     
    %für plots speichern
    plots.CoarseCFO(k) = CoarseCFO;
    plots.FineCFO(k)=FineCFO;
end

