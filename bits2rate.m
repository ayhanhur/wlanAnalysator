function [RateMBit,RateIndex,ModulationM,ModulationKmod]=bits2rate(signalBits)
    
% Ndbps = [ 24 36 48 72 96 144 192 216 24 ];
% Ncbps = [ 48 48 96 96 192 192 288 288 48 ];

% bitstrings= strrep(num2str(signalBits'), ' ', '');
% switch bitstrings
%     case '1101'
%         RateMBit  = 6;
%     case '1111'
%         RateMBit  = 9;
%     case '0101'
%         RateMBit  = 12;
%     case '0111'
%         RateMBit  = 18;
%     case '1001'
%         RateMBit  = 24;
%     case '1011'
%         RateMBit  = 36;
%     case '0001'
%         RateMBit  = 48;
%     case '0011'
%         RateMBit  = 54;
%     otherwise
%         error('illegal datarate')
% end
% dataRate = [ 6 9 12 18 24 36 48 54 ];
% RateIndex  = find(dataRate==RateMBit);

%%%
% RateIndex=9 --> illegales Datarate 
% 

RateNumber   = [ 8 4 2 1 ]*signalBits+1; %4 bits rate    
Overboard    = 9;
RateIndexTab = [ Overboard 7 Overboard  8 Overboard 3 Overboard 4 Overboard 5 Overboard 6 Overboard 1 Overboard 2 ] ; % Overboard Entries to avoid index out of bounds
RateIndex    = RateIndexTab(RateNumber);


RateTab           = [ 6 9 12 18 24 36 48 54 6]; 
ModulationMTab    = [ 2 2 4 4 16 16 64 64 2]; % BPSK ,QPSK, 16QAM 64QAM
ModulationKmodTab = [ 1 1 1/sqrt(2) 1/sqrt(2) 1/sqrt(10) 1/sqrt(10) 1/sqrt(42) 1/sqrt(42) 1 ];
 

RateMBit       = RateTab(RateIndex);
ModulationM    = ModulationMTab(RateIndex);
ModulationKmod = ModulationKmodTab(RateIndex);


