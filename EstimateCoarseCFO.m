function CoarseCFO=EstimateCoarseCFO(Packet,ft,WindowCoarseCFO,PeriodShortPreamble)
% grobe schätzung der frequenzversatz
% Coarse Estimation of center Frequency
% ft=20e6
% PeriodShortPreamble=16;
% WindowCoarseCFO=64;

ang=angle(sum(Packet(1:WindowCoarseCFO).*conj(Packet((1:WindowCoarseCFO)+PeriodShortPreamble))));
CoarseCFO=-ang/(2*pi/ft*PeriodShortPreamble);

