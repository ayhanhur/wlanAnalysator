function bits = myde2bi(dec, binits)
% MYDE2BI optimized implementation of de2bi MATLAB function.
%   BITS = MYDE2BI(DEC, BINITS) is a replacement for the following low
%   performance MATLAB operations:
%
%   In case of
%         bits = reshape(de2bi(symbols,2)', 1, 192);
%   use
%         bits = myde2bi(symbols, 2);
%
%   In case of
%         bits = reshape(de2bi(symbols,3)', 1, 288);
%   use
%         bits = myde2bi(symbols, 3);
%
%   This implementation makes use of lookup-tables for decimal->binary conversion
%   and is faster than the corresponding MATLAB implementation using de2bi.
%
%   If DEC contains invalid numbers (e.g. 42 has no corresponding 3 bit
%   representation) this function will fail.
%
% See also: MYBI2DE, DEMAPPER (hard decision case)
%


destlen = length(dec)*binits;

bits = zeros(1, destlen);

dec = dec + 1; % MATLAB array indexing starts at 1

if binits == 2
    binit2_1 = [0 0 1 1];  % MSB
    binit2_0 = [0 1 0 1];  % LSB

    bits(2:2:destlen) = binit2_1(dec);
    bits(1:2:destlen) = binit2_0(dec);
elseif binits == 3
    binit2_2 = [0 0 0 0 1 1 1 1]; % MSB
    binit2_1 = [0 0 1 1 0 0 1 1];
    binit2_0 = [0 1 0 1 0 1 0 1]; % LSB

    bits(3:3:destlen) = binit2_2(dec);
    bits(2:3:destlen) = binit2_1(dec);
    bits(1:3:destlen) = binit2_0(dec);
else
    error('binits is restricted to 2 or 3!')
end
