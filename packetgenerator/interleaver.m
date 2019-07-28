function inter = interleaver(s, n_bpsc)
%INTERLEAVER   Führt das Interleaving nach IEEE802.11a durch

n_cbps=n_bpsc*48;

if ~(mod(length(s),n_cbps))
    signal=s;
else
    signal=[s zeros(1,n_cbps-mod(length(s),n_cbps))];
end

i_pattern=(n_cbps/16)*mod(0:n_cbps-1,16)+floor((0:n_cbps-1)/16);
s=max(n_bpsc/2,1);
j_pattern=s*floor(i_pattern/s)+mod((i_pattern+n_cbps-floor(16*i_pattern/n_cbps)),s);
j_pattern=j_pattern+1;

n_symbols=length(signal)/n_cbps;

tmp=0:n_cbps:(n_symbols-1)*n_cbps;
tmp=repmat(tmp,n_cbps,1);
inter_pattern=tmp(:)'+repmat(j_pattern,1,n_symbols);

inter=zeros(1,length(signal));
inter(inter_pattern)=signal;

%SignalFieldCode = SignalFieldCode(mod(0:3:3*48-1,48)+floor((0:47)/16)+1);%deinterleaving