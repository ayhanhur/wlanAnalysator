function [ofdm_symbols,dataBitsCrc] = txData(Mbps,Bytes)
%% 
%Mbps -> Datenrate
%Bytes -> Nutzdaten in Byte
%

dataRate = [ 6 9 12 18 24 36 48 54 ];
ind = find(dataRate==Mbps);
%coderate
R = [ 1/2 3/4 1/2 3/4 1/2 3/4 2/3 3/4 ];
coderate=R(ind);
% Data bits per OFDM symbol (NDBPS)
Ndbps = [ 24 36 48 72 96 144 192 216 ];
Ndbps=Ndbps(ind);
% Coded bits per subcarrier (NBPSC)
Nbpsc = [ 1 1 2 2 4 4 6 6 ];
Nbpsc=Nbpsc(ind);
% Coded bits per OFDM symbol (NCBPS)
Ncbps = [ 48 48 96 96 192 192 288 288 ];
Ncbps = Ncbps(ind);

g_x=[1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];
% g_x(end:-1:1)=g_x;
dataBits=randint(1,(Bytes-4)*8); %ohne crc
[ crcBits, dataBitsCrc ]= calcCrc(dataBits,g_x); %Daten mit CRC 
%bytes = length(dataBitsCrc)/8;

%%%%% SETUP DATA BITS %%%%%
Nsym      = ceil(( 16 + length(dataBitsCrc) +  6 ) / Ndbps);
Ndata     = Ndbps * Nsym ;

% generate padded bitstream with SERVICE field for OFDM
allBits = zeros(1, Ndata);
allBits(17:16+length(dataBitsCrc)) = dataBitsCrc;% data starts after SERVICE field

if mod(Ndata , Ndbps) ~= 0
    error('the number of data bits must be a multiple of Ndbps')
end


%%%%% 1. CONVOLUTIONAL ENCODING %%%%%
% scrambling
scrData = pngen(length(allBits), [1 0 1 1 1 0 1]);
scrData = xor(scrData, allBits)*1;
scrData(16 + length(dataBitsCrc)+1:16 + length(dataBitsCrc)+6) = 0; %Tailbits


trellis   = poly2trellis(7,[133 171]);
codedData = convenc(scrData, trellis);


% if necessary (coderate ~= 1/2) puncture the output of the convolutional encoder
if coderate ~= 1/2
% codedData = codedData(punc(coderate,Ncbps,Ndbps));
   codedData = tx_puncture(codedData, coderate);
end

%%%%% 3. INTERLEAVE %%%%%
 ciData = interleaver(codedData,Nbpsc);
% idx = simplemkinterleave(Ncbps);
% ciData(idx) = codedData; % Und De-Interleaven


%%%%% 4. MAP BITS ONTO SCs %%%%%

d_ciData = modulator(ciData, Nbpsc);

N_sym    = length(d_ciData)/48; %48 Unterträger 
d_ciData = reshape(d_ciData,48, N_sym);

map_ciData = zeros(64,N_sym);
map_ciData([7:11 13:25 27:32 34:39 41:53 55:59],:) = d_ciData;    % Spaltenweises Mapping der komplexen Werte auf die einzelnen Subträger

% Pilotsymbole einfügen
PilotScramble = [1 1 1 1 -1 -1 -1 1 -1 -1 -1 -1 1 1 -1 1 -1 -1 1 1 -1 1 1 -1 1 1 1 1 ...
      1 1 -1 1 1 1 -1 1 1 -1 -1 1 1 1 -1 1 -1 -1 -1 1 -1 1 -1 -1 1 -1 -1 1 1 1 1 1 -1 -1 1 ...
      1 -1 -1 1 -1 1 -1 1 1 -1 -1 -1 1 1 -1 -1 -1 -1 1 -1 -1 1 -1 1 1 1 1 -1 1 -1 1 -1 1 -1 ...
      -1 -1 -1 -1 1 -1 1 1 -1 1 -1 1 1 1 -1 -1 1 -1 -1 -1 1 1 1 -1 -1 -1 -1 -1 -1 -1];

scr_pilot = PilotScramble( mod(1:N_sym,length(PilotScramble))+1 );
map_ciData([12 26 40 54],:) = repmat(scr_pilot, 4,1).*repmat([1;1;1;-1], 1, N_sym);%Piloten scramblen

map_ciData([33:64 1:32],:) = map_ciData; % für IFFT Umsortieren , damit Mittenfrequenzen dem Gleichanteil (DC) enstprechen.

ifft_data    = ifft(map_ciData);     % IFFT
ofdm_symbols = gi_w(ifft_data); %+GI

