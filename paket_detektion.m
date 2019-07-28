function  [PacketPositions]=paket_detektion(signal)


%--------------------------------------------------------------------------
% Pakete lokalisieren  
%--------------------------------------------------------------------------

global FractionDetected
global ThresholdPacketDetection
global CorrelationWindowPacketDetection
global WindowPacketFindSmooth
global PeriodShortPreamble
global LengthShortPreamble
global plots

d = signal(1:end-PeriodShortPreamble);  % d=Verz�gertes PeriodShortPreamble=16
e = signal(PeriodShortPreamble+1:end);  % e=Original

% Packet Detektieren
% Korrelation berechnen und Mitteln und Leistungsnormierung:
% CorrelationWindowPacketDetection=32;
CorrelationShortPreamble = abs(conv(ones(CorrelationWindowPacketDetection,1),conj(d).*e))./...
    max(conv(ones(CorrelationWindowPacketDetection,1),abs(d).^2),conv(ones(CorrelationWindowPacketDetection,1),abs(e).^2));  

% Durch Mittelung verl�ngerte Korrelation abschneiden.
CorrelationShortPreamble = CorrelationShortPreamble(1:end-(CorrelationWindowPacketDetection-1)); 
CorrelationShortPreamble(1:100)=0; % Einschwinger der Resampling-Filter am Anfang Weg

% Auswerten der Korrelationsoberfl�che
%ThresholdPacketDetection=0.8
PacketCandidates = CorrelationShortPreamble > ThresholdPacketDetection; % Kandidaten finden

 % Fenster dr�ber
 % WindowPacketFindSmooth=9
SmoothedPacketCandidates = conv(PacketCandidates*1,ones(WindowPacketFindSmooth,1))/WindowPacketFindSmooth;

% Entscheiden ob genug Anteil da ist
% FractionDetected=0.3
SmoothedPacketCandidates = SmoothedPacketCandidates > FractionDetected; 

% Gefundene Pakete sind mindestens die Short Preamble lang, um
% Mehrfachdetektionen innerhalb eines Paktes zu vermeiden
% LengthShortPreamble=160
SmoothedPacketCandidates = conv(SmoothedPacketCandidates*1.0,ones(LengthShortPreamble,1))>0; 

% Primitiv-Filter sucht steigende Flanken um Paketanf�nge zu detektieren
SmoothedPacketCandidates = conv(SmoothedPacketCandidates*1,[1,-1])>0; 
SmoothedPacketCandidates = SmoothedPacketCandidates(1:length(PacketCandidates));
PacketPositions          = find(SmoothedPacketCandidates);

%f�r Plotten merken
plots.signal = signal;
plots.PacketCandidates         = PacketCandidates; 
plots.CorrelationShortPreamble = CorrelationShortPreamble;




