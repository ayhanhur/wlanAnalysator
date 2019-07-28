function ofdm_symbols = txSignal(Mbps,bytes)

% Mbps  -> Datenrate 
% bytes -> Übertragene datenlänge (MAC header mit FCS ...)


%%%%% 0. CONSTRUCT SIGNAL FIELD %%%%%
signalBits = zeros(1, 24);

% write rate bits
switch Mbps
    case 6
        signalBits(1:4) = [1 1 0 1];
    case 9
        signalBits(1:4) = [1 1 1 1];
    case 12
        signalBits(1:4) = [0 1 0 1];
    case 18
        signalBits(1:4) = [0 1 1 1];
    case 24
        signalBits(1:4) = [1 0 0 1];
    case 36
        signalBits(1:4) = [1 0 1 1];
    case 48
        signalBits(1:4) = [0 0 0 1];
    case 54
        signalBits(1:4) = [0 0 1 1];
    otherwise
        error('illegal datarate')
end


bits = dectobin(bytes, 12); % write length

signalBits(6:17) = bits;
signalBits(18)   = mod(sum(signalBits), 2);%Parity

trellis     = poly2trellis(7,[133 171]);

codedSignal = convenc(signalBits, trellis);
ciSignal    = interleaver(codedSignal,1);

%d_signal = modulator(ciSignal,1); %mapping/modulation

% modObj = modem.pskmod('M', 2);
% d_signal =modulate(modObj,ciSignal);
d_signal = mapper(ciSignal,1);


map_signal = zeros(64,1);
map_signal([7:11 13:25 27:32 34:39 41:53 55:59])=d_signal;    % Spaltenweises Mapping der komplexen Werte auf die einzelnen Subträger

map_signal(12, :)= 1;   % Pilotsymbole einfügen
map_signal(26, :)= 1;
map_signal(40, :)= 1;
map_signal(54, :)=-1;

map_signal([33:64 1:32]) = map_signal; % für IFFT Umsortieren , damit Mittenfrequenzen dem Gleichanteil (DC) enstprechen.

ifft_signal=ifft(map_signal);  % IFFT
ofdm_symbols = gi_w(ifft_signal);%+GI

