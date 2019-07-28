function init()
%--------------------------------------------------------------------------
% 802.11a Konstanten
%
%--------------------------------------------------------------------------
%
global ThresholdPacketDetection
global FractionDetected
global WindowPacketFindSmooth
global MinimumPacketSize
global CorrelationWindowPacketDetection
global AddShift
global WindowCoarseCFO
global WindowFineCFO
global ft
global PeriodShortPreamble
global PeriodLongPreamble
global LengthShortPreamble
global LengthLongPreamble
global SymbolLength
global OverallSymbolLength
global GuardInterval
global PadBitsFront
global PadBitsRear
global p ref
global trellis
global SignOfPilots

global plots

% Konstanten IEEE 802.11a:
%
% Packet Detection: Schwelle für Korrelationsverhältnis 
% PHIss(16)/PHIss(0)nach Mittelung über L1
ThresholdPacketDetection=0.8;

% Anteil der zu einer Preamble gehörenden Abtastwerte im Fenster, 
% damit ein Paket erkannt wird
FractionDetected=0.3; 

% Innerhalb dieses Fensters muss ein Anteil von FractionDetected Abtastwerte
% ein Paket signalisieren, dann wird ein Paket erkannt.
WindowPacketFindSmooth=9;     

% Minimale Paketlänge, auf die sich die Algorithmen verlassen können
MinimumPacketSize=1000; 

% Fenster für Korrelation bei Paket Detektion
CorrelationWindowPacketDetection=32;    

% Zusätzliche Verzögerung in Bezug auf den Paketstart
AddShift=4;  

% Fenster über das bei Coarse CFO in Short Preamble gemittelt wird
WindowCoarseCFO=64;
       
% Fenster über das bei Coarse CFO in Short Preamble gemittelt wird
WindowFineCFO=32;



% Abtastfrequenz 20 MHz
ft=20e6;  

% Periode der Short Preamble
% t_1 bis t_10  10 shorttrainingssymbol t_shortsym=0.8 microsec => 0.8 microsec*20MHz = 16
PeriodShortPreamble=16;

% Periode der Long Preamble
% T_1 und T_2 2 longtrainingssymbols T_longsym=3.2 microsec.
PeriodLongPreamble=64; 

% Länger der Long Preamble
% T_short= 8 microsec. Short Training Sequence Duration (8 microsec.* 20 MHz =160)
LengthShortPreamble=160;

% Länger der Short Preamble
% T_long=0.8*10= 8 microsec. Short Training Sequence Duration (8 microsec. * 20 MHz=160)
LengthLongPreamble=160;

% T_FFT  20MHz/64Unterträger=0.3125 ->Unterträgerfrequenz 1/0.3125=3.2
% microsec , 3.2 microsec*20MHz=64
SymbolLength=64;

% T_sym Symbolintervall = 4 microsec. guardintervall+symbollänge
OverallSymbolLength=80;

% T_GI: Guard Intervall duration=0.8 microsec. 0.8 microsec. * 20 Mhz=16
GuardInterval=OverallSymbolLength-SymbolLength;

%Für SignalField
PadBitsFront=16;

PadBitsRear=6;

% Scramble-Pilotensequenz nach Standard IEEE802.11a
SignOfPilots= [1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1, -1,1,1,-1, 1,1,1,1, 1,1,-1,1,...
    1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1,...
    -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, 1,-1,1,1, 1,1,-1,1, -1,1,-1,1,...
    -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1, 1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1] ;



[p,ref]=generate_preamble; %präambel und referenzsignal 

trellis = poly2trellis(7,[133 171]);

%globale variablen für plotsfunktionen
plots = struct( 'signal',[],...
                'CorrelationShortPreamble',[],...
                'CoarseCFO',[],...
                'FineCFO',[],...
                'SignalFieldEVM',[],...
                'PacketCandidates',[],...
                'SignalFieldPlot', [],...
                'PacketParityOK',[],...
                'PacketTrailerOK' ,[],...
                'PacketOFDMSymbol',[],...
                'PacketAngle' ,[],...
                'PacketPilot' ,[],...
                'crcError' ,[]);


