function LongPreambleStart= estimate_LP1(Packet)

global ref
global AddShift
global SymbolLength
global LengthShortPreamble
global GuardInterval

% Paketposition Erkennen 
% Long Preamble im Frequenzbereich raussuchen
S  = ref(:, 3);           %Long Preamble 
S  = [S(33:64); S(1:32)]; % Passend auf FFT sortieren
S2 = [S(2:end); 0];       % Mit versatz
Sd = -1*S.*S2;            % Preambel im Frequenzbereich korrelieren

%% Symbolposition schätzen
    LongPreamble = Packet(SymbolLength/2+(LengthShortPreamble+(1:SymbolLength)));
    Y  = (fft(LongPreamble));
    Y2 = [Y(2:end); 0]; % Einen Träger verschieben.
    Yd = conj(Y).*Y2;   % Im Frequuenzbereich korrelieren
    M  = sum(Yd.*Sd);   % Dann Kreuzkorrelation
    us_freq = -angle(M)/(2*pi)*SymbolLength-SymbolLength/2; % Die Symbollänge ist erstmal geraten 
    LongPreambleStart = ceil(LengthShortPreamble+us_freq)+floor(GuardInterval/2)+AddShift;
    