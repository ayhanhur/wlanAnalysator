function d=modulator(bits, Nbpsc)

dimBits=length(bits);

if mod(dimBits, Nbpsc) ~= 0
    error('number of message bits is no multiple of Nbpsc');
end


switch Nbpsc

    case 1  %'BPSK'
        
       %  b0
       % '0' -1 
       % '1'  1

        Kmod = 1;
        
        I  = 2*bits-1;
        Q  = zeros(1,dimBits);
    
    case 2 %'QPSK'
       
       %  b0b1
       % '0' -1 
       % '1'  1
       
        Kmod = 1/sqrt(2);
      
        I  = 2*bits(1:2:end)-1;
        Q  = 2*bits(2:2:end)-1;

    case 4 %'16QAM'
        
        % b0b1b2b3
        %'00' -3 
        %'01' -1 
        %'11' 1 
        %'10' 3 
        
        
        bits    = reshape(bits, 2, []);
        mod_tab = [-3,3,-1,1];
        
        Kmod = 1/sqrt(10);
        
        I = mod_tab(2.^[0 1]*bits(:,1:2:end)+1);
        Q = mod_tab(2.^[0 1]*bits(:,2:2:end)+1);

    case 6 %'64QAM'
        
        % '000' -7
        % '001' -5
        % '011' -3 
        % '010' -1 
        % '110' 1 
        % '111' 3 
        % '101' 5 
        % '100' 7 
        
        bits    = reshape(bits, 3, []);
        mod_tab = [-7,7,-1,1,-5,5,-3,3];
        
        Kmod = 1/sqrt(42);
        
        I = mod_tab(2.^[0 1 2]*bits(:,1:2:end)+1);
        Q = mod_tab(2.^[0 1 2]*bits(:,2:2:end)+1);
        
    otherwise
    error('number of bits per subcarrier must be 1, 2, 4 or 6')
end

d=(I+j*Q)*Kmod;
