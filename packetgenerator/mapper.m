function [coeff] = mapper(symbits, param)
% coeff = mapper(cmessage, Nbpsc)
%
% Author: Christian Schilling <christian.schilling@uni-dortmund.de>

Nbpsc = param;

numBits = length(symbits);
numCoeff = numBits / Nbpsc;

if mod(numBits, Nbpsc) ~= 0
    error('number of message bits is no multiple of Nbpsc');
end


switch Nbpsc
case 1   % BPSK (hier ist nicht viel zu tun)
    I = 2*symbits - 1;
    Q = zeros(1, numBits);
    Kmod = 1;
case 2   % QPSK
    I = 2*symbits(1:2:numCoeff*2)-1;
    Q = 2*symbits(2:2:numCoeff*2)-1;
    Kmod = 1/sqrt(2);
case 4  % 16-QAM
    mod_tab = [-3 3 -1 1];           % ACHTUNG: indices bit reversed + 1
    %bits_grouped = bi2de(reshape(symbits, 2, [])')';
    bits_grouped = mybi2de(symbits, 2);
    I = mod_tab(bits_grouped(1:2:numCoeff*2)+1);
    Q = mod_tab(bits_grouped(2:2:numCoeff*2)+1);
    Kmod = 1/sqrt(10);
case 6  % 64-QAM
    mod_tab = [-7 7 -1 1 -5 5 -3 3]; % ACHUNG: indices bit reversed + 1
    %bits_grouped = mybi2de(reshape(symbits, 3, [])')';
    bits_grouped = mybi2de(symbits, 3);
  %  bits_grouped
    I = mod_tab(bits_grouped(1:2:numCoeff*2)+1);
    Q = mod_tab(bits_grouped(2:2:numCoeff*2)+1);
    %
    Kmod = 1/sqrt(42);
otherwise
    error('number of bits per subcarrier must be 1, 2, 4 or 6')
end

coeff = Kmod * (I + i*Q);


%coeff = [zeros(1,6) coeff(1:5) pilot coeff(6:18) pilot coeff(19:24) 0 coeff(25:30) pilot coeff(31:43) -pilot coeff(44:48) zeros(1,6)];
