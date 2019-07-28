function [OFDMSymbols,SignalFieldPackets]=signal_field(PacketPositions,Packet,LongPreambleStart)

% +-----------+--------+----------+------+
% + Preamble  + Signal + Daten    + CRC  +
% +-----------+--------+----------+------+
%Auswertung Signal Field

%% Variablen
global LengthShortPreamble
global LengthLongPreamble
global SymbolLength
global OverallSymbolLength
global PadBitsFront 
global PadBitsRear
global ft   
global ref
global trellis

global plots


for k=1:length(PacketPositions) 
%% Paket Korrelation Kanaleinflüsse
    
    KOR = estimate_channel(Packet{k},LongPreambleStart(k));
    
%% SignalField ausschneiden
    snap = Packet{k}(LongPreambleStart(k)+2*OverallSymbolLength+(0:SymbolLength-1));
    SignalField = fftshift(fft(snap));
    SignalField = SignalField.*KOR;
    
    Pilots      = SignalField(33+[-21 -7 7 21]).*[1 1 1 -1]';
    SignalField = SignalField*exp(-j*mean(angle(Pilots))); 
    
    %% demodulieren
    demodObj = modem.pskdemod('M', 2); %BPSK
    SignalFieldCode = demodulate(demodObj,-SignalField);
    
    %% für plots merken
    modObj = modem.pskmod('M', 2);
    SignalFieldEVM = sqrt(sum((abs((modulate(modObj,SignalFieldCode)+SignalField).*ref(:,3))).^2)/sum(abs(ref(:,3))));
    plots.SignalFieldEVM(k)  = SignalFieldEVM;
    plots.SignalFieldPlot{k} = SignalField;
    
    %% pilot symbole entfernen
    x=ref(:,3); x(33+[-21 -7 7 21]) = 0;
    SignalFieldCode = SignalFieldCode(find(x));    

    %% deinterleaving 
    SignalFieldCode = SignalFieldCode(mod(0:3:3*48-1,48)+floor((0:47)/16)+1);%deinterleaving

    %% decodierung
    decoded = vitdec([ SignalFieldCode ] ,trellis,48/2,'trunc','hard'); %decodieren
    
    [PacketRateMBit, RateIndex ,PacketModulationM ,PacketModulationKmod] = bits2rate(decoded(1:4)); %
    
    PacketLength    = 2.^(0:11)*decoded(6:17); %12 bits length[ MSB(niedrigste bitwert2^0)...LSB(höchste bitwert2^n)]
    PacketParityOK  = (0==mod(sum(decoded(1:18)),2)); % Parity bit 'Bit 17'
    PacketTrailerOK = sum(decoded(19:end))==0; % signal tail bits all 6 bits = '0'
    
    %RateIndex=9 illegales Datarate 
    PacketOK = RateIndex~=9 && PacketTrailerOK && PacketParityOK && PacketRateMBit~=0 ...
               && (PacketPositions(k)+LongPreambleStart(k)-LengthShortPreamble) >= 1;
       
%% Anzahl gültige OFDM Symbole in Datenfelds 
    if PacketOK
        %Anzahl Symbole Nsym
        OFDMSymbols(k) = ceil((PacketLength*8+PadBitsFront+PadBitsRear)/(PacketRateMBit*(OverallSymbolLength/ft*1e6)));
        
        if (LongPreambleStart(k)+(OFDMSymbols(k)+1)*OverallSymbolLength+LengthLongPreamble) > length(Packet{k})
            PacketOK = 0; 
            OFDMSymbols(k)=0;
        end
    else
        OFDMSymbols(k)=0;
    end
    
%% Daten für weitere Analyse der Paketen  in Strukt speichern
    SignalFieldPackets{k}.RateIndex  = RateIndex;
    SignalFieldPackets{k}.Modulation = PacketModulationM;
    SignalFieldPackets{k}.Rate       = PacketRateMBit;
    SignalFieldPackets{k}.Length     = PacketLength;
    SignalFieldPackets{k}.PacketOK   = PacketOK;
    SignalFieldPackets{k}.PacketKOR  = KOR;
    
    SignalFieldPackets{k}.PacketModulationKmod = PacketModulationKmod;
    
    %für plots merken
    plots.PacketParityOK(k)  = PacketParityOK;
    plots.PacketTrailerOK(k) = PacketTrailerOK;
end