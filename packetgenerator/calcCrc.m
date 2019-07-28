function [ crcBits,dataBitsCrc ]= calcCrc(msg,g_x)

%% CRC bits generieren  msg bin�r

if nargin==1
 g_x=[1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];%generatorpolynom
end

%data = dectobin(msg,8,'msb');
data = [msg zeros(1,length(g_x)-1)]; %am Ende  mit Nullen f�llen 
data(1:32) = bitcmp(data(1:32),1);   %erste 32 bit invertieren


for i=1:length(data)
    bit=data(i);
    if (bit==1) && (length(data)+1-i >= length(g_x)) 
        data(i:i+length(g_x)-1)=bitxor(data(i:i+length(g_x)-1),g_x);
    else
        rest(i)=bit;
    end
end

crcBits = rest(length(rest)-length(g_x)+2:end); %Divisions Rest 
crcBits = bitcmp(crcBits,1);  %Invertieren
 
% crcBits=dectobin(dezimal,8,'msb');
% crcBits = reshape(crcBits,8,4);
% crcBits(end:-1:1,1:4)=crcBits;
% crcBits = crcBits(:);

dataBitsCrc = [msg crcBits]; % An original Nachricht anh�ngen

       