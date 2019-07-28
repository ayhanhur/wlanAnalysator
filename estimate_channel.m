function KOR=estimate_channel(Packet,LongPreambleStart)

global ref
global SymbolLength
global GuardInterval


    %% Paket Korrelation Kanaleinflüsse
    
    snap = Packet(GuardInterval+LongPreambleStart+(0:SymbolLength-1));
    h1   = fftshift(fft(snap)).*ref(:,3);
    
    snap = Packet(GuardInterval+SymbolLength+LongPreambleStart+(0:SymbolLength-1));
    h2   = fftshift(fft(snap)).*ref(:,3);
    
    %korrelation
    KOR = 1./((h1+h2)*0.5);
    KOR(find(abs(KOR)>1e15)) = 0;
    