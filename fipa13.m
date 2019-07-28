function [All,PacketLength,PacketRateMBit,PacketOK]=fipa13(c,offset)
All=[];
ThresholdPacketDetection=0.8;           % Packet Detection: Schwelle für Korrelationsverhältnis PHIss(16)/PHIss(0) nach Mittelung über L1
CorrelationWindowPacketDetection=32;    % Fenster für Korrelation bei Paket Detektion
AddShift=4;                            % Zusätzliche Verzögerung in Bezug auf den Paketstart
global WindowCoarseCFO; WindowCoarseCFO=64;        % Fenster über das bei Coarse CFO in Short Preamble gemittelt wird
global WindowFineCFO; WindowFineCFO=32;        % Fenster über das bei Coarse CFO in Short Preamble gemittelt wird

WindowPacketFindSmooth=9;   % Innerhalb dieses Fensters muss ein Anteil von FractionDetected Abtastwerte
% ein Paket signalisieren, dann wird ein Paket
% erkannt.
FractionDetected=0.3;       % Anteil der zu einer Preamble gehörenden Abtastwerte im Fenster,
% damit ein Paket werkannt wird

% Konstannten 11a:
MinimumPacketSize=1000; % Minimale Paketlänge, auf die sich die Algorithmen verlassen können;
global ft; ft=20e6;   % Abtastfrequenz 
global PeriodShortPreamble; PeriodShortPreamble=16;% Periode der Short Preamble
global PeriodLongPreamble; PeriodLongPreamble=64; % Periode der Short Preamble
global LengthShortPreamble; LengthShortPreamble=160;% Länger der Short Preamble
global LengthLongPreamble; LengthLongPreamble=160;% Länger der Short Preamble
global SymbolLength; SymbolLength=64;
global OverallSymbolLength; OverallSymbolLength=80;
global GuardInterval; GuardInterval=OverallSymbolLength-SymbolLength;
global PadBitsFront; PadBitsFront=16;
global PadBitsRear; PadBitsRear=6;
% Was soll geplottet werden
PlotInputAndPreambleCorrelation=1;
PlotPacketFinds=1;
PlotPrambleFFTs=1;
PlotConstellations=1;

t=(1:length(c))/ft;
cc=c.*exp(j*2*pi*t'*(-offset));  % Hier muss man pfuschen, wenn das Eingangssignal einen zu großen Frequenzoffset hat!

d=cc(1:end-PeriodShortPreamble); e=cc(PeriodShortPreamble+1:end); % e=Original, d= Verzögertes
% Korrelation berechnen und Mitteln und Leistungsnormierung:
CorrelationShortPreamble= ...
    abs(conv(ones(CorrelationWindowPacketDetection,1),conj(d).*e)) ...
    ./ ...
    max( ...
    conv(ones(CorrelationWindowPacketDetection,1),abs(d).^2), ...
    conv(ones(CorrelationWindowPacketDetection,1),abs(e).^2) ...
    );  %% Siehe Arbeit Markus Bochenko

CorrelationShortPreamble=CorrelationShortPreamble(1:end-(CorrelationWindowPacketDetection-1)); % Durch Mittelung verlängerte Korrelation abschnieden.
CorrelationShortPreamble(1:100)=0; % Einschwing-Mist der Resampling-Filter am Anfang Weg

% Auswerten der Korrelationsoberfläche
PacketCandidates=CorrelationShortPreamble>ThresholdPacketDetection; % Kandidaten finden


SmoothedPacketCandidates=conv(PacketCandidates*1,ones(WindowPacketFindSmooth,1))/WindowPacketFindSmooth; % Fenster drüber
SmoothedPacketCandidates=SmoothedPacketCandidates>FractionDetected; % Entscheiden ob genug Anteil da ist
% Gefundene Pakete sind mindestens die Short Preamble lang, um
% Mehrfachdetektionen innerhalb eines Paktes zu vermeiden

SmoothedPacketCandidates=conv(SmoothedPacketCandidates*1.0,ones(LengthShortPreamble,1))>0; % Gefundene Pakete sind mindestens die
SmoothedPacketCandidates=conv(SmoothedPacketCandidates*1,[1,-1])>0; % Primitiv-Filter sucht steigende Flanken um Paketanfänge zu detektieren
SmoothedPacketCandidates=SmoothedPacketCandidates(1:length(PacketCandidates));
PacketPositions=find(SmoothedPacketCandidates);



if length(PacketPositions)==0 ; disp('No Packets found.'); return;  end;

for k=1:length(PacketPositions)
    Packet{k}=d(PacketPositions(k):end);                % Cut out single Packets
    Packet{k}=[ Packet{k} ; zeros(max(MinimumPacketSize,MinimumPacketSize-length(Packet{k})),1) ]; % Jedes Paket ist dann mindestens 100 lang
    CoarseCFO(k)=EstimateCoarseCFO(Packet{k});          % Coarse Estimation of center Frequency
    t=(1:length(Packet{k}))/ft;                         % Markus Bochenko
    Packet{k}=Packet{k}.*exp(j*2*pi*(t')*(-CoarseCFO(k)));  % And imideate Correction of CFO
end

for k=1:length(PacketPositions)
    LongPreamble=Packet{k}(LengthShortPreamble+(1:2*PeriodLongPreamble)); % Da ist ein bischen mehr drin, wg. Verspätung Detektor;
    FineCFO(k)=EstimateFineCFO(Packet{k});          % Fine Estimation of center Frequency Sebastian Wietz
    t=(1:length(Packet{k}))/ft;
    Packet{k}=Packet{k}.*exp(j*2*pi*(t')*(-FineCFO(k)));  % And imideate Correction of CFO;
end

% Paketposition Erkennen Sebastian Wietz
[p,ref]=generate_preamble;
S=ref(:, 3);      % Long Preamble im Frequenzbereich raussuchen
S=[S(33:64); S(1:32)]; % Passend auf FFT sortieren
S2=[S(2:end); 0];      % Mit versatz
Sd=-1*S.*S2;          % Preambel im Freqnezbereich korrelieren

for k=1:length(PacketPositions)
    LongPreamble=Packet{k}(SymbolLength/2+(LengthShortPreamble+(1:SymbolLength)));
    Y=(fft(LongPreamble)); % Siehe Diplomarbeit Wietz, erstmal DFT
    Y2=[Y(2:end); 0]; % Einen Träger verschieben.
    Yd=conj(Y).*Y2;  % Im Frequuenzbereich korrelieren
    M=sum(Yd.*Sd);         % Dann Kreuzkorrelation
    us_freq=-angle(M)/(2*pi)*SymbolLength-SymbolLength/2; % Die Symbollänge ist erstmal geraten
    LongPreambleStart(k)=ceil(LengthShortPreamble+us_freq)+floor(GuardInterval/2)+AddShift;
end



% Auswertung SignalField
for k=1:length(PacketPositions);
    snap=Packet{k}(GuardInterval+LongPreambleStart(k)+(0:SymbolLength-1));
    h1=fftshift(fft(snap)).*ref(:,3);
    snap=Packet{k}(GuardInterval+SymbolLength+LongPreambleStart(k)+(0:SymbolLength-1));
    h2=fftshift(fft(snap)).*ref(:,3);
    KOR=1./((h1+h2)*0.5);
    KOR(find(abs(KOR)>1e15))=0;
    PacketKOR(k,:)=KOR;
    snap=Packet{k}(LongPreambleStart(k)+2*OverallSymbolLength+(0:SymbolLength-1));
    SignalField=fftshift(fft(snap));
    SignalField=SignalField.*KOR;
    Pilots=SignalField(33+[-21 -7 7 21].*[1 1 1 -1]);
    SignalField=SignalField*exp(-j*mean(angle(Pilots)));
    %SignalField=SignalField/mean(Pilots);
    SignalFieldPlot{k}=SignalField;
    modObj = modem.pskdemod('M', 2);
    %modem.pskdemod(modObj,'DecisionType',llrtype,'NoiseVariance',noisepower,'SymbolOrder','gray');
    SignalFieldCode=demodulate(modObj,-SignalField);
    modObj = modem.pskmod('M', 2);
    SignalFieldEVM(k)=sqrt(sum((abs((modulate(modObj,SignalFieldCode)+SignalField).*ref(:,3))).^2)/sum(abs(ref(:,3))));
    x=ref(:,3); x(33+[-21 -7 7 21])=0;
    SignalFieldCode=SignalFieldCode(find(x));
    SignalFieldCode=SignalFieldCode(mod(0:3:3*48-1,48)+floor((0:47)/16)+1);
    trellis = poly2trellis(7,[133 171]);
    decoded=vitdec([ SignalFieldCode ] ,trellis,48/2,'trunc','hard');
    RateNumber(k)=[ 8 4 2 1 ]*decoded(1:4)+1;
    Overboard=9;
    RateIndexTab=[ Overboard 7 Overboard  8 Overboard 3 Overboard 4 Overboard 5 Overboard 6 Overboard 1 Overboard 2 ] ; % Overboard Entries to avoid index out of bounds
    RateIndex(k)=RateIndexTab(RateNumber(k));
    RateTab=[ 6 9 12 18 24 36 48 54 6];
    ModulationMTab=[ 2 2 4 4 16 16 64 64 2];
    ModulationKmodTab=[ 1 1 1/sqrt(2) 1/sqrt(2) 1/sqrt(10) 1/sqrt(10) 1/sqrt(42) 1/sqrt(42) 1 ];
    PacketModulationKmod(k)=ModulationKmodTab(RateIndex(k));
    PacketRateMBit(k)=RateTab(RateIndex(k));
    PacketModulationM(k)=ModulationMTab(RateIndex(k));
    PacketLength(k)=2.^(0:11)*decoded(6:17);
    PacketParityOK(k)=(0==mod(sum(decoded(1:18)),2));
    PacketTrailerOK(k)=sum(decoded(19:end))==0;
    PacketOK(k)=PacketTrailerOK(k) && PacketParityOK(k) && PacketRateMBit(k)~=0 && (PacketPositions(k)+LongPreambleStart(k)-LengthShortPreamble)>=1;
    if PacketOK(k)
        OFDMSymbols(k)=ceil((PacketLength(k)*8+PadBitsFront+PadBitsRear)/(PacketRateMBit(k)*(OverallSymbolLength/ft*1e6)));
        if LongPreambleStart(k)+(OFDMSymbols(k)+1)*OverallSymbolLength+LengthLongPreamble > length(Packet{k});
            PacketOK(k)=0; OFDMSymbols(k)=0;
        end
    else
        OFDMSymbols(k)=0;
    end
end

PacketGapAfter=0*PacketPositions; % Später für die Plots schon mal die Abstände zwischen den gültigen Paketen besorgen
for k=1:length(PacketPositions)-1
    if  PacketOK(k+1) && PacketOK(k)
        PacketGapAfter(k)=PacketPositions(k+1)-LengthShortPreamble+LongPreambleStart(k+1) ...
            -( PacketPositions(k)+LengthLongPreamble+LongPreambleStart(k)+OverallSymbolLength*(OFDMSymbols(k)+1) );
    else
        PacketGapAfter(k)=-1;
    end
end

SignOfPilots= [1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1, -1,1,1,-1, 1,1,1,1, 1,1,-1,1,...
    1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1,...
    -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, 1,-1,1,1, 1,1,-1,1, -1,1,-1,1,...
    -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1, 1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1] ;

for k=1:length(PacketPositions)
    
    if PacketOK(k)
        PacketDemodulated{k}=[];

        for kk=1:OFDMSymbols(k)
            ActualSinghOfPilots=SignOfPilots( mod(kk,length(SignOfPilots))+1 );
            snap=Packet{k}(LongPreambleStart(k)+LengthLongPreamble++OverallSymbolLength+(kk-1)*OverallSymbolLength+(0:SymbolLength-1));
            KOR=PacketKOR(k,:); KOR=KOR.';
            OFDMSymbol=fftshift(fft(snap)).*KOR / PacketModulationKmod(k);
            

            PacketPilot{k}(kk,:)=OFDMSymbol(33+[-21 -7 7 21])*ActualSinghOfPilots; % Für Plots merken
            Pilots=OFDMSymbol(33+[-21 -7 7 21].*[1 1 1 -1])*ActualSinghOfPilots;
            OFDMSymbol=OFDMSymbol*exp(-j*mean(angle(Pilots))); % Aus welcher Richtung blaen die Piloten?

            x=ref(:,3); x(33+[-21 -7 7 21])=0; % Piloten uund Kroppzeug am Rand und in der Mitte weg
            OFDMSymbol=OFDMSymbol(find(x));

            PacketOFDMSymbol{k}(kk,:)=OFDMSymbol; % Merken für die Plots
            PacketAngle{k}(kk)=angle(mean(Pilots));

            max(real(OFDMSymbol));
            
            modObj = modem.qamdemod('M', PacketModulationM(k), 'PhaseOffset', 0, 'SymbolOrder','gray', 'OutputType', 'integer', 'DecisionType','hard decision');
            OFDMSymbolCode=demodulate(modObj,conj(OFDMSymbol)); % Demapper;

            bits='1'==dec2bin(real(OFDMSymbolCode),log2(PacketModulationM(k))) ; % Aus den Mapper-Zahlen Bits machen. I = MSBs, Q=LSBs
            bits=bits'; bits=bits(:); % Bits serialisieren

            NCBPS=log2(PacketModulationM(k))*length(OFDMSymbol); % De-Interleaver ausrechnen
            idx = simplemkinterleave(NCBPS);
            bits(idx) = bits; % Und De-Interleaven

            PacketDemodulated{k}=[ PacketDemodulated{k}; bits ]; % Bits an schon decodiertes dranhängen
        end

        bits=PacketDemodulated{k};

        switch RateIndex(k)
            case { 2,4,6,8 }
                ppat= [  1 1 1 0 0 1  ]; % restliche Modes Mit Punktierung
            case 7
                ppat=[ 1 1 1 0 ]; % 48 Mbit-Mode
            otherwise    % R=1/2, nix Punktierung
        end
        switch RateIndex(k) % Witerbi-Decoder mit oder ohne Punktierung
            case { 2,4,6,7,8 }
                decoded=vitdec([ bits ] ,trellis,48/2,'trunc','hard',ppat ) ;
            otherwise
                decoded=vitdec([ bits ] ,trellis,48/2,'trunc','hard');
        end

        g=decoded(7:-1:1);  % Desccrambler erstmal initialisieren
        scr=g;              % Anfängliche Sequenz = 7 Bit der Eingangsfolge
        for i=1:length(decoded)-7;   % PRN für die Restlichen ausrechenen
            g=[ mod(g(7)+g(4),2) ; g(1:6)];  % Das ist das Polynom
            scr= [ scr ; g(1) ];  % Ein Bit zur PRN dazu
        end
        data=mod(scr+decoded,2);  % descamblen
        All{k}.data=data(1:PacketLength(k)*8+16);
        data=data(17:end); data=data(1:PacketLength(k)*8);
%          All{k}.crc=crcTest(data');
        data=reshape(data,8,length(data)/8);
        otto=[];
        for i=1:size(data,2)
            otto(i)=sum(data(:,i).*(2.^[0:7])');
        end
        All{k}.Data=otto;

    end
end



if PlotInputAndPreambleCorrelation
    figure;
    subplot(2,1,1);
    pwelch(d); % Leistungsdichte Eingangssignal
    subplot(2,1,2)
    hold on;
    plot(1:length(PacketCandidates),PacketCandidates,'r');
    plot((1:length(CorrelationShortPreamble)),CorrelationShortPreamble,'b') % Korrelation im Abstand 16
    axis([-inf inf -0.2 1.2])
    hold off
end

if PlotInputAndPreambleCorrelation
    figure;     hold on;
    plot((1:length(d)),0*abs(d),'k')
    plot((1:length(d)),abs(d),'g') % Hüllkurve Eingangssignal

    DMAX=max(abs(d));
    for k=1:length(PacketPositions); MPM(k)=mean(abs(Packet{k}(1:LengthShortPreamble))); end
    axis([-Inf Inf -DMAX*0.3 Inf ]);
    plot(PacketPositions,1.2*MPM,'v','LineWidth',2,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','b',...
        'MarkerSize',5);
    plot((PacketPositions+LengthLongPreamble)+LongPreambleStart',MPM,'^','LineWidth',2,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','b',...
        'MarkerSize',5);
    for k=1:length(PacketPositions)
        if(PacketOK(k)>0)
            plot(PacketPositions(k)+LengthLongPreamble+LongPreambleStart(k)+OverallSymbolLength*(OFDMSymbols(k)+1),0,'^','LineWidth',2,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','b',...
                'MarkerSize',5);
            plot(PacketPositions(k)-LengthShortPreamble+LongPreambleStart(k),0,'^','LineWidth',2,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor','b',...
                'MarkerSize',5);
        end


    end
    for k=1:length(PacketPositions)
        col='black'; if ~PacketOK(k) ; col='red'; end
        us='';
        if PacketOK(k)
            us=sprintf('\n%3.1fus',(OverallSymbolLength*(OFDMSymbols(k)+1)+LengthLongPreamble+LengthShortPreamble)/ft*1e6);
        end

        us=sprintf('%dMbit/s\n%dByte%s\n',PacketRateMBit(k),PacketLength(k),us);
        if PacketOK(k)
            byte1=dec2hex(All{k}.Data(1),2);
            us=sprintf('%s1. Byte: %s\n',us,byte1);
            switch All{k}.Data(1)
                case { hex2dec('D4') }
                    if length(All{k}.Data)>=10
                        MAC1=[];
                        for kk=5:10
                            MAC1=[ MAC1 dec2hex(All{k}.Data(kk),2) ' '];
                        end
                        us=sprintf('%s1. MAC: %s\n',us,MAC1);
                    end
                case { hex2dec('88') }
                    if length(All{k}.Data)>=16
                        MAC1=[]; MAC2=[];
                        for kk=5:10
                            MAC1=[ MAC1 dec2hex(All{k}.Data(kk),2) ' '];
                        end
                        for kk=11:16
                            MAC2=[ MAC2 dec2hex(All{k}.Data(kk),2) ' '];
                        end
                        us=sprintf('%s1. MAC: %s\n',us,MAC1);
                        us=sprintf('%s2. MAC: %s\n',us,MAC2);

                    end
                otherwise
            end
        end
        us=sprintf('%sOffs.:\n%3.1f KHz\n%4.1f Hz',us,CoarseCFO(k)/1000,FineCFO(k));
        us=sprintf('%s\nEVM.: %1.2f',us,SignalFieldEVM(k));
        text(PacketPositions(k),2*MPM(k),us,'HorizontalAlignment','left','Color',col)

        if PacketGapAfter(k)>=0 && k<length(PacketPositions)
            gap=PacketGapAfter(k)/ft*1e6;
            us=sprintf('%3.1fus',gap);
            middle=(PacketPositions(k)+LengthLongPreamble+LongPreambleStart(k)+OverallSymbolLength*(OFDMSymbols(k)+1) ...
                +(PacketPositions(k+1)-LengthShortPreamble+LongPreambleStart(k+1)))/2;
            text(middle,-0.1*DMAX,us,'HorizontalAlignment','center','Color','black')
        end
    end
    hold off;
end

if PlotPacketFinds
    P=ceil(sqrt(length(PacketPositions)));
    P2=ceil(length(PacketPositions)/P);
    figure;

    PS=max(max(abs(real(d)),max(abs(imag(d)))));
    for k=1:length(PacketPositions)
        subplot(P,P2,k);
        PP=Packet{k}(1:MinimumPacketSize);
        hold on;
        plot(1:MinimumPacketSize,real(PP),'r');
        plot(1:MinimumPacketSize,imag(PP),'b');
        axis([-inf inf -1.1*PS 1.1*PS]);
        plot(LongPreambleStart(k),0,'^','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','r',...
            'MarkerSize',5);
        plot(LengthLongPreamble+LongPreambleStart(k),0*PacketPositions,'^','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','r',...
            'MarkerSize',5);
        if(PacketOK(k)>0)
            ending=LengthLongPreamble+LongPreambleStart(k)+OverallSymbolLength*(OFDMSymbols(k)+1);
            if ending>MinimumPacketSize
                ending=MinimumPacketSize; marker='>';
            else
                marker='^';
            end
            plot(ending,0,marker,'LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','b',...
                'MarkerSize',5);
            plot(-LengthShortPreamble+LongPreambleStart(k),0,'^','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','b',...
                'MarkerSize',5);
        end

        ok='OK'; col='black'; if (0==PacketParityOK(k));  ok='not OK'; col='red'; end
        if PacketRateMBit(k)==0 ; col='red'; end
        fd=sprintf('%d MBit/s %d Bytes Parity %s',PacketRateMBit(k),PacketLength(k),ok);
        text(10,0.8*PS,fd,'HorizontalAlignment','left','color',col)
        hold off
    end

    figure

    for k=1:length(PacketPositions)
        subplot(P,P2,k);
        PP=Packet{k}(1:MinimumPacketSize);
        hold on;
        for kk=1:length(SignalFieldPlot{k})
            rete=clipit(real(SignalFieldPlot{k}(kk)),2);
            imte=clipit(imag(SignalFieldPlot{k}(kk)),2);
            axis([-2 2 -2 2]);
            if rete~=real(SignalFieldPlot{k}(kk)) || imte ~= imag(SignalFieldPlot{k}(kk))
                col='red';
            else
                col='blue';
            end
            plot(clipit(real(SignalFieldPlot{k}(kk)),2)+j*clipit(imag(SignalFieldPlot{k}(kk)),2),'o','MarkerEdgeColor',col)
        end
        pok='OK'; tok=pok; col='black';
        if (0==PacketParityOK(k)) ;pok='not OK'; col='red'; end
        if (0==PacketTrailerOK(k)) ;tok='not OK'; col='red'; end
        fd=sprintf('%d MBit/s %d Bytes \nPar. %s Trail. %s EVM %1.2f',PacketRateMBit(k),PacketLength(k),pok,tok,SignalFieldEVM(k));
        text(-1.8,1.4,fd,'HorizontalAlignment','left','color',col)
        hold off
    end

end


if PlotPrambleFFTs
    figure
    for k=1:length(PacketPositions)
        plot([-32:31],abs(fftshift(fft(Packet{k}(1+0*LongPreambleStart(k)+(0:SymbolLength-1))))))
        hold on;
    end

    figure
    for k=1:length(PacketPositions)
        plot([-32:31],abs(fftshift(fft(Packet{k}(LongPreambleStart(k)+(0:SymbolLength-1))))))
        hold on;
    end

    figure
    for k=1:length(PacketPositions)
        plot([-32:31],abs(fftshift(fft(Packet{k}(LongPreambleStart(k)+OverallSymbolLength+(0:SymbolLength-1))))))
        hold on;
    end
end

if PlotConstellations
    figure;
    P=ceil(sqrt(length(PacketPositions)));
    P2=ceil(length(PacketPositions)/P);

    for k=1:length(PacketPositions)
        subplot(P,P2,k);

        hold on;

        SizeTab=[ 2 2 2 2 6 6 6 10 8 ]; 

        Siz=SizeTab(RateIndex(k));

        axis([ -Siz Siz -Siz Siz ]);

        if PacketOK(k)


            for kkk=1:OFDMSymbols(k)

                for kk=1:length(PacketOFDMSymbol{k}(kkk,:))
                    rete=clipit(real(PacketOFDMSymbol{k}(kkk,kk)),Siz);
                    imte=clipit(imag(PacketOFDMSymbol{k}(kkk,kk)),Siz);

                    if rete~=real(PacketOFDMSymbol{k}(kkk,kk)) || imte ~= imag(PacketOFDMSymbol{k}(kkk,kk))
                        col='red';
                    else
                        col='blue';
                    end
                    plot(clipit(real(PacketOFDMSymbol{k}(kkk,kk)),Siz)+j*clipit(imag(PacketOFDMSymbol{k}(kkk,kk)),Siz),'o','MarkerEdgeColor',col)
                end

                for i=-(max(2,sqrt(PacketModulationM(k)))-2):2:(max(2,sqrt(PacketModulationM(k)))-2)
                    col=[1 1 1 ]*0.7;
                    plot( [ -Siz Siz ] , [ i i], 'Color', col);
                    plot( [i i ], [ -Siz Siz ] , 'Color', col);
                end
                % plot(PacketOFDMSymbol{k}(kkk,:),'o','MarkerEdgeColor','b');
                col=['r','y','g','c'];
                for i=1:4
                    plot(PacketPilot{k}(kkk,i)/exp(j*PacketAngle{k}(kkk)),'+','MarkerEdgeColor',col(i));
                end
                

            end
        pok='OK'; tok=pok; col='black';
        if (0==PacketParityOK(k)) ;pok='not OK'; col='red'; end
        if (0==PacketTrailerOK(k)) ;tok='not OK'; col='red'; end
        fd=sprintf('%d MBit/s %d Bytes \nPar. %s Trail. %s EVM %1.2f',PacketRateMBit(k),PacketLength(k),pok,tok,SignalFieldEVM(k));
        xlabel(fd,'color',col)
        end
    end

end
end



function done=clipit(what,onto)
done=onto*(what>onto)+what.*(what<=onto);
done=-onto*(done<-onto)+done.*(done>=(-onto));
end

function idx = simplemkinterleave(Ncbps)
% MKINTERLEAVE Make interleaver indices.
%
%   IDX = SIMPLEMKINTERLEAVE(NCBPS) generates a vector to map NCBPS
%   bits according to the block interleaver described in
%   IEEE-802.11a. NCBPS is the number of coded bits per OFDM symbol.
%

%   Example:
%     idx = simplemkinterleave(192);
%     data_deinterleaved      = zeros(1, 192);
%     data_deinterleaved(idx) = data_interleaved;

% Author: Christian Schilling <christian.schilling@udo.edu>
% W. Endemann thank Schling and modiefied it.

if (Ncbps ~= 288) & (Ncbps ~= 192) & (Ncbps ~= 96) & (Ncbps ~= 48)
    error('no valid number of coded bits per symbol (Ncbps)');
end

Nbpsc = Ncbps / 48; % calculate number of bits per subcarrier

% The following lines correspond to the permutation formulas given in the
% standard, except that n is used as source indices of both steps.
n = 0:Ncbps-1;

i = (Ncbps/16) * mod(n, 16) + floor(n/16);

idx    = zeros(1, Ncbps);
idx(i+1) = n;

s = max(Nbpsc/2, 1);
j = s*floor(n/s) + mod((n + Ncbps - floor(16*n/Ncbps)),s);
idx(j+1) = idx + 1;

end

function CoarseCFO=EstimateCoarseCFO(Packet)

global ft;
global PeriodShortPreamble;

global WindowCoarseCFO;

ang=angle(sum(Packet(1:WindowCoarseCFO).*conj(Packet((1:WindowCoarseCFO)+PeriodShortPreamble))));
CoarseCFO=-ang/(2*pi/ft*PeriodShortPreamble);

end

function FineCFO=EstimateFineCFO(Packet)
global ft;
global PeriodLongPreamble;
global WindowFineCFO;
ang=angle(sum(Packet(1:WindowFineCFO).*conj(Packet((1:WindowFineCFO)+PeriodLongPreamble))));
FineCFO=-ang/(2*pi/ft*PeriodLongPreamble);
end


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

tdr=ifft(fdr([N/2+1:end 1:N/2], :));    %Spaltenweise beide H�lften vertauschen und dann IFFT
ref=[sp_fdr tdr(:, 1) lp_fdr tdr(:, 2)];

sp_tdr=tdr(:, 1);   % Die Short-Preamble hat eine Periodenl�nge von ifft_length/4=16 Samples, da nur jeder vierte Subtr�ger ungleich 0 ist.
sp_tdr=[sp_tdr; sp_tdr; sp_tdr(1:N/2+1)];   % Short-Preamble auf 10 Perioden+1 Samples=161 Samples zyklisch erweitern
w=[0.5 ones(1, 10*N/4-1) 0.5]';  % Fensterfunktion
sp_tdr=sp_tdr.*w;   % Short-Preamble fenstern

lp_tdr=tdr(:, 2);   % Long-Preamble
gi=lp_tdr(N/2+1:end);    % Der Long Preamble wird ein Guard-Intervall (GI) doppelter L�nge vorangestellt
gi_lp_tdr=[gi; lp_tdr; lp_tdr; lp_tdr(1)]; % Long Preamble auf insgesamt GI + 2 Perioden + 1 (161 Samples) zyklisch erweitern
gi_lp_tdr=gi_lp_tdr.*w;

%p=gi_lp_tdr;
%p=sp_tdr;
p=[sp_tdr(1:end-1); sp_tdr(end)+gi_lp_tdr(1); gi_lp_tdr(2:end)];    % �berlappung beider Pr�ambeln

end

