function transmission=create_trans(signal,snr,freq_o)

s=signal*64/sqrt(52);

% if (chan)
%     h=ricianchan(1/20e6,4,4,[0 (1e-7)*rand(1,19)],linspace(0,-20,20));
%     s=filter(h,s);
% end

%noise variance

nv=64/52/(10^(snr/10))/2;
len=size(s,2);

%add nosie ti ssignal

noise_s=sqrt(nv)*randn(1,len)+j*sqrt(nv)*randn(1,len);
s=s+noise_s;

%noiseee

len=499;
noise_f=sqrt(nv)*randn(1,len)+j*sqrt(nv)*randn(1,len);

%%end noise
len=300;
noise_e=sqrt(nv)*randn(1,len)+j*sqrt(nv)*randn(1,len);

trans=[noise_f s' noise_e];

samp_freq=20e6;

t=(0:length(trans)-1)/samp_freq;

offset=exp(j*2*pi*freq_o*t);

transmission=trans.*offset;

