function [ crcBits,dataBitsCrc ]= calcCrc(msg,g_x)

%% CRC bits generieren 802.11a msg binär

if nargin==1
 g_x=[1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];%generatorpolynom
end

%data = dectobin(msg,8,'msb');
data = [msg zeros(1,length(g_x)-1)];
data(1:32) = bitcmp(data(1:32),1);


for i=1:length(data)
    bit=data(i);
    if (bit==1) && (length(data)+1-i >= length(g_x)) 
        data(i:i+length(g_x)-1)=bitxor(data(i:i+length(g_x)-1),g_x);
    else
        rest(i)=bit;
    end
end

crcBits = rest(length(rest)-length(g_x)+2:end);
crcBits = bitcmp(crcBits,1);
 
% crcBits=dectobin(dezimal,8,'msb');
% crcBits = reshape(crcBits,8,4);
% crcBits(end:-1:1,1:4)=crcBits;
% crcBits = crcBits(:);

dataBitsCrc = [msg crcBits];

       