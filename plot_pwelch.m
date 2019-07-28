function plot_pwelch()

global plots
global ft

% [Pxx,w] = pwelch(x) estimates the power spectral density Pxx of the input 
% signal vector x using Welch's averaged modified periodogram method of spectral 
% estimation. With this syntax:
% The vector x is segmented into eight sections of equal length, each with 50% overlap.
% Any remaining (trailing) entries in x that cannot be included in the eight segments 
% of equal length are discarded.
% Each segment is windowed with a Hamming window (see hamming) that is the same
% length as the segment.

 d = plots.signal;
 [Pxx,w] = pwelch(d);
 
    figure('Name','Spektrale Leistungsdichte','NumberTitle','off');
    %pwelch(d);  % Leistungsdichte Eingangssignal
    pwelch(d,w,0,[],ft);
    
    