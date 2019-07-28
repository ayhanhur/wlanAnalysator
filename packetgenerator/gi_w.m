function [ofdm_symbols] = gi_w(ifft_signal)

[ifft_length, Nsym]=size(ifft_signal);

gi=ifft_signal([3/4*ifft_length+1:ifft_length], :); %GI bilden (Zeitsignal zyklisch fortsetzen)

gi_ifft_signal=[gi;ifft_signal];    % GI am Anfang einfügen

[Ncoeff, Nsym]=size(gi_ifft_signal);

w=[0.5 ones(1, Ncoeff-2) 0.5]'; % Fensterfunktion

for i=1:Nsym
    ofdm_symbols(:, i)=gi_ifft_signal(:, i).*w; % Zeitsignal fenstern
end
