function FineCFO=EstimateFineCFO(Packet,ft,PeriodLongPreamble,WindowFineCFO)
%--------------------------------------------------------------------------
%WindowFineCFO=32;
%PeriodLongPreamble=64;
%Feine Sch�tzung
%
%--------------------------------------------------------------------------


ang=angle(sum(Packet(1:WindowFineCFO).*conj(Packet((1:WindowFineCFO)+PeriodLongPreamble))));
FineCFO=-ang/(2*pi/ft*PeriodLongPreamble);

