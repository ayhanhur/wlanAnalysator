function idx = simplemkinterleave(Ncbps)

%--------------------------------------------------------------------------
%   MKINTERLEAVE Make interleaver indices.
%
%   IDX = SIMPLEMKINTERLEAVE(NCBPS) generates a vector to map NCBPS
%   bits according to the block interleaver described in
%   IEEE-802.11a. NCBPS is the number of coded bits per OFDM symbol.
%
%
%    Example:
%     idx = simplemkinterleave(192);
%     data_deinterleaved      = zeros(1, 192);
%     data_deinterleaved(idx) = data_interleaved;
%
%   Author: Christian Schilling <christian.schilling@udo.edu>
%   W. Endemann thank Schling and modiefied it.
%--------------------------------------------------------------------------

if (Ncbps ~= 288) & (Ncbps ~= 192) & (Ncbps ~= 96) & (Ncbps ~= 48)
    error('no valid number of coded bits per symbol (Ncbps)');
end

Nbpsc = Ncbps / 48; % calculate number of bits per subcarrier

% The following lines correspond to the permutation formulas given in the
% standard, except that n is used as source indices of both steps.
n = 0:Ncbps-1;

i = (Ncbps/16) * mod(n, 16) + floor(n/16);

idx    = zeros(1, Ncbps);
idx(i+1) = n;

s = max(Nbpsc/2, 1);
j = s*floor(n/s) + mod((n + Ncbps - floor(16*n/Ncbps)),s);
idx(j+1) = idx + 1;

