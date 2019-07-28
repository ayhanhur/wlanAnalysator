function binData=dectobin(decData,dim,opt)

% default LSB erste Bit

bitStrings = dec2bin(decData,dim); %bitstrings

if nargin>2
    if strcmpi(opt, 'msb')
     binData = double(reshape(bitStrings', 1, [])) - double('0');  %MSB left    
    end
    if strcmpi(opt, 'lsb')
        bitStrings(:,end:-1:1)=bitStrings;
        binData = double(reshape(bitStrings', 1, [])) - double('0'); %LSB left
    end
else
    bitStrings(:,end:-1:1)=bitStrings;
    binData = double(reshape(bitStrings', 1, [])) - double('0'); %LSB left
     
end




  