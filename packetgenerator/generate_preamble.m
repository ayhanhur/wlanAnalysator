function [p, ref] = generate_preamble

N=64;

sp_fdr=zeros(N, 1);   % Short Preamble
sp_fdr([9 17 29 45 49 53 57])=1+i;
sp_fdr([13 21 25 37 41])=-1-i;
sp_fdr=sqrt(13/6)*sp_fdr;   %Short-Preamble normalisieren

lp_fdr=ones(N, 1);    % Long Preamble
lp_fdr([1:6 N/2+1 60:64])=0;   % lp(33)=dc
lp_fdr([9 10 13 15 22 23 26 28 35 36 39 41 43:47 50 51 53 55])=-1;

fdr=[sp_fdr lp_fdr];

tdr=ifft(fdr([N/2+1:end 1:N/2], :));    %Spaltenweise beide Hälften vertauschen und dann IFFT
ref=[sp_fdr tdr(:, 1) lp_fdr tdr(:, 2)];

sp_tdr=tdr(:, 1);   % Die Short-Preamble hat eine Periodenlänge von ifft_length/4=16 Samples, da nur jeder vierte Subträger ungleich 0 ist.
sp_tdr=[sp_tdr; sp_tdr; sp_tdr(1:N/2+1)];   % Short-Preamble auf 10 Perioden+1 Samples=161 Samples zyklisch erweitern
w=[0.5 ones(1, 10*N/4-1) 0.5]';  % Fensterfunktion
sp_tdr=sp_tdr.*w;   % Short-Preamble fenstern

lp_tdr=tdr(:, 2);   % Long-Preamble
gi=lp_tdr(N/2+1:end);    % Der Long Preamble wird ein Guard-Intervall (GI) doppelter Länge vorangestellt
gi_lp_tdr=[gi; lp_tdr; lp_tdr; lp_tdr(1)]; % Long Preamble auf insgesamt GI + 2 Perioden + 1 (161 Samples) zyklisch erweitern
gi_lp_tdr=gi_lp_tdr.*w; 

%p=gi_lp_tdr;
%p=sp_tdr;
p=[sp_tdr(1:end-1); sp_tdr(end)+gi_lp_tdr(1); gi_lp_tdr(2:end)];    % Überlappung beider Präambeln
