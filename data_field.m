function [DataPackets,CRC32]= data_field(PacketPositions,Packet,LongPreambleStart,OFDMSymbols,SignalFieldPackets)
%% Data Field Auswerten

global LengthLongPreamble
global SymbolLength
global OverallSymbolLength
global SignOfPilots
global ref 

global plots

DataPackets=[];
CRC32=[];

sym=find(OFDMSymbols==0);
if length(sym) == length(PacketPositions)
    disp([' All Packets Invalid!! ']);
return;
elseif ~isempty(sym)
        disp(['Invalid:  ',num2str(length(sym))]);
        disp('-----------------------------------------------------------------');
end

for k=1:length(PacketPositions)
    %% Aus SignalField Paket Merkmale laden
    PacketModulationM    = SignalFieldPackets{k}.Modulation;
    PacketRateMBit       = SignalFieldPackets{k}.Rate;
    PacketLength         = SignalFieldPackets{k}.Length;
    PacketOK             = SignalFieldPackets{k}.PacketOK;
    PacketKOR            = SignalFieldPackets{k}.PacketKOR;
    PacketModulationKmod = SignalFieldPackets{k}.PacketModulationKmod;
    RateIndex            = SignalFieldPackets{k}.RateIndex;
    
    if PacketOK
        
        PacketDemodulated=[];
        
        disp([num2str(k),'.Paket ---> '  , num2str(OFDMSymbols(k)), ' Symbols ']);
        disp(['Paketrate: ',num2str(PacketRateMBit),'Mbit  | Paketlänge: ',...
               num2str(PacketLength),' Byte | Modulation: ',num2str(PacketModulationM),' QAM']);
        
        for kk=1:OFDMSymbols(k)
         %% Data Field Ausschneiden   
            ActualSinghOfPilots = SignOfPilots( mod(kk,length(SignOfPilots))+1 );
         
            snap = Packet{k}(LongPreambleStart(k)+LengthLongPreamble+OverallSymbolLength+(kk-1)*OverallSymbolLength+(0:SymbolLength-1));
            KOR  = PacketKOR; 
            OFDMSymbol = fftshift(fft(snap)).*KOR / PacketModulationKmod;
            Pilots = OFDMSymbol(33+[-21 -7 7 21]).*[1 1 1 -1]'*ActualSinghOfPilots;
            
            %für plots merken
            plots.PacketPilot{k}(kk,:) = OFDMSymbol(33+[-21 -7 7 21])*ActualSinghOfPilots; 
            plots.PacketAngle{k}(kk)   = angle(mean(Pilots));
            
            % Aus welcher Richtung blaen die Piloten?
            OFDMSymbol = OFDMSymbol*exp(-j*mean(angle(Pilots))); 
            % Piloten und Kroppzeug am Rand und in der  Mitte weg
            x=ref(:,3); x(33+[-21 -7 7 21])=0;
            OFDMSymbol = OFDMSymbol(find(x)); 
     
            % Merken für die Plots
            plots.PacketOFDMSymbol{k}(kk,:) = OFDMSymbol; 
            
        
            %% Demodulieren          
            bits = demodulator(OFDMSymbol,PacketModulationM);
            
            %%softdec
            %addpath('./dede')
            %soft_bits= rx_demodulate(OFDMSymbol, PacketModulationM);
            %out_bits = rx_viterbi_decode(soft_bits);
            %% De-Interleaver ausrechnen
            NCBPS = log2(PacketModulationM)*length(OFDMSymbol); 
            idx   = simplemkinterleave(NCBPS);
            bits(idx) = bits; % De-Interleaven
            PacketDemodulated=[ PacketDemodulated; bits ]; % Bits an schon decodiertes dranhängen
        end
        
        bits    = PacketDemodulated;
        decoded = dep_decoder(bits,RateIndex);%%Depunktierung Decodierung
        data    = descrambler(decoded); %%Descrambling
        
        DataPackets{k}.bitiService = data(1:PacketLength*8+16); % mit service bits
        data = data(17:end); % ohne service bits
        data = data(1:PacketLength*8); %mac header+nutzdaten+crc
        
        DataPackets{k}.dataBits = data;
        DataPackets{k}.decData  = bintodec(data,8); %nutzdaten als dezimal
        
        %% CRC Check
        g_x=[1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];%generatorpolynom
        %g_x(end:-1:1)=g_x;
        [crcError,rest]=crc32_check(DataPackets{k}.dataBits',g_x);
 
        if ~crcError
            message=' CRC OK.';
        else
            message=' CRC Error!';
        end
        
        DataPackets{k}.CRC32_check = message; %In struct speichern 
        CRC32{k} = crcError; %ausgabe als cell array
        
        display(['CRC Check .............: ',message]);
        
                                                          
%% MAC FRAME :
DataPackets{k}.MAC_DATA  = mac_frame(data,DataPackets{k}.decData);
DataPackets{k}.MAC_DATA.FCS = data(end-31:end);

  disp('-----------------------------------------------------------------');
    else
        DataPackets{k}=[];
        CRC32{k}=[];
        disp([num2str(k),'.Paket Invalid']);
        if RateIndex==9
            disp('Illegal Datarate in Signalfield');
        end
        disp('-----------------------------------------------------------------');
        
    end
 plots.crcError=CRC32; %für plotten speichern 
end


 