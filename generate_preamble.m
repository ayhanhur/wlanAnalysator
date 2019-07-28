function [p, ref] = generate_preamble

N=64; %träger anzahl

sp_fdr=zeros(N, 1);   % Short Preamble
sp_fdr([9 17 29 45 49 53 57])=1+i;
sp_fdr([13 21 25 37 41])=-1-i;
sp_fdr=sqrt(13/6)*sp_fdr;   %Short-Preamble normalisieren


lp_fdr=ones(N, 1);    % Long Preamble
lp_fdr([1:6 N/2+1 60:64])=0;   % lp(33)=dc
lp_fdr([9 10 13 15 22 23 26 28 35 36 39 41 43:47 50 51 53 55])=-1;

% Auf FFT Sortierte preamble
% sp_fdr([39:64 2:27]) = sqrt(13/6)*[ ...
%     0 0 1+i 0 0 0 -1-i 0 0 0 1+i 0 0 0 -1-i 0 0 0 -1-i 0 0 0 1+i 0 0 0 ...
%     0 0 0 -1-i 0 0 0 -1-i 0 0 0 1+i 0 0 0 1+i 0 0 0 1+i 0 0 0 1+i 0 0]';
% lp_fdr=zeros(N, 1);
% lp_fdr([39:64 2:27]) = [ ...
%     1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 ...
%     1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1]';


fdr=[sp_fdr lp_fdr];

%Spaltenweise beide Hälften vertauschen und dann IFFT
tdr=ifft(fdr([N/2+1:end 1:N/2], :));    
ref=[sp_fdr tdr(:, 1) lp_fdr tdr(:, 2)];

% Die Short-Preamble hat eine Periodenlänge von ifft_length/4=16 Samples, 
% da nur jeder vierte Subträger ungleich 0 ist.
sp_tdr=tdr(:, 1);  

% Short-Preamble auf 10 Perioden+1 Samples=161 Samples zyklisch erweitern
sp_tdr=[sp_tdr; sp_tdr; sp_tdr(1:N/2+1)];   
w=[0.5 ones(1, 10*N/4-1) 0.5]';  % Fensterfunktion

% Short-Preamble fenstern
sp_tdr=sp_tdr.*w;   

lp_tdr=tdr(:, 2);   % Long-Preamble
% Der Long Preamble wird ein Guard-Intervall (GI) doppelter Länge vorangestellt
gi=lp_tdr(N/2+1:end);  

% Long Preamble auf insgesamt GI + 2 Perioden + 1 (161 Samples) zyklisch erweitern
gi_lp_tdr=[gi; lp_tdr; lp_tdr; lp_tdr(1)];
gi_lp_tdr=gi_lp_tdr.*w;

%p=gi_lp_tdr;
%p=sp_tdr;
%Überlappung beider Präambeln
p=[sp_tdr(1:end-1); sp_tdr(end)+gi_lp_tdr(1); gi_lp_tdr(2:end)];    

