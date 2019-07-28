function [crcError,rest]=crc32_check(msg,g_x)

%% CRC-Check   802.11a


if nargin<2
% g_x=zeros(1,33); g_x(32-[32 26 23 22 16 12 11 10 8 7 5 4 2 1 0]+1)=1;
g_x=[1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];%generatorpolynom
end

 octets  = msg(1:end-32);
 crcbits = msg(end-31:end);  
 data    = [octets bitcmp(crcbits,1)]; %komplement crc bits
 data(1:32)= bitcmp(data(1:32),1); %komplement ersten 32 bits initialisieren mit 1 xor 1

for i=1:length(data)
    bit=data(i);
    if (bit==1) && (length(data)+1-i >= length(g_x)) 
        data(i:i+length(g_x)-1) = bitxor(data(i:i+length(g_x)-1),g_x);
    else
        rest(i)=bit;
    end
end

if sum(rest)== 0
    crcError = 0;% kein Fehler
else
    crcError = 1;% Fehler
end 

