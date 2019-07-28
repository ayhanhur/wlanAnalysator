function packets_80211a = analyse(signal,varargin)


% signal: zu anlaysierende Signal für .mat file >> 'namedesSignals' oder aus workspace value name
% varargin: name des plots als string z.b 'constellation' oder alles 'all'-> analyse(signal,'all')


if  ischar(signal)
    load(signal);
    datei = whos('-file', signal);
    s = [ 'signal = ' datei.name ';' ];
    eval(s);
end

init(); %konstanten laden 
[PacketPositions] = paket_detektion(signal);%Pakete finden

if isempty(PacketPositions) 
    disp('...No Packets found!...');
    packets_80211a=[];
    return;
else
PaketAnzahl=length(PacketPositions);
disp(['===================',num2str(PaketAnzahl),' Packets found.','=================']);
end

[Packet,LongPreambleStart] = paket_korrektur (signal,PacketPositions); %pakete korrigieren

[OFDMSymbols,SignalFieldPackets] = signal_field(PacketPositions,Packet,LongPreambleStart); % signal feld auswerten gültige symbole merken

[DataPackets,CRC32] = data_field(PacketPositions,Packet,LongPreambleStart,OFDMSymbols,SignalFieldPackets);%daten feld auswerten

%% Falls erwünscht alle Ergebnisse in ein Matlab Cell Array speichern (in Workspace) Nach Paketen Sortieren
if nargout==1
       packets_80211a=[];
        if  ~isempty(SignalFieldPackets) 
        for i=1:length(PacketPositions)
            
           % s = [ 'allPackets.Packet' int2str(i) '.SignalField=SignalFieldPackets{' num2str(i) '};'];
           % eval(s);
           % s = [ 'allPackets.Packet' int2str(i) '.DataField=DataPackets{' num2str(i) '};'];
           % eval(s);
           % s = [ 'allPackets.Packet' int2str(i) '.FCSField=CRC32{' num2str(i) '};'];
           % eval(s);
           
           packets_80211a{i,1}.SignalField=SignalFieldPackets{i};
           if  ~isempty(DataPackets) 
           packets_80211a{i}.DataField=DataPackets{i};
           else
               packets_80211a{i,1}.DataField=[];
           end
           if  ~isempty(DataPackets) 
           packets_80211a{i}.FCSField=CRC32{i};
           else
               packets_80211a{i,1}.FCSField=[];
           end
           
        end
        end
end   

%% Plots Grafische Ausgaben
if  nargin>1
    
        for i=1:length(varargin)
   
            if    strcmpi(varargin(i), 'constellation') 
                
               plot_constellations(PacketPositions,OFDMSymbols,SignalFieldPackets);  
            
            elseif strcmpi(varargin(i), 'packets') 
                
               plot_PacketFinds(PacketPositions,LongPreambleStart,Packet,OFDMSymbols,SignalFieldPackets);
               
            elseif strcmpi(varargin(i), 'preamble') 
                
               plot_preambleFFT(PacketPositions,Packet,LongPreambleStart);
               
            elseif strcmpi(varargin(i), 'correlation') 
                
               plot_InputAndPreambleCorrelation();
               
            elseif strcmpi(varargin(i), 'pwelch') 
                
               plot_pwelch();
               
            elseif strcmpi(varargin(i), 'input') 
                
                plot_InputAndPackets(PacketPositions,LongPreambleStart,...
                             Packet,OFDMSymbols, SignalFieldPackets,DataPackets);
             % cell2mat(varargin(i))==1
            elseif (strcmpi(varargin(i), 'all')||strcmpi(varargin(i), 'plots')) && (length(varargin)==1)
                plot_PacketFinds(PacketPositions,LongPreambleStart,Packet,OFDMSymbols,SignalFieldPackets);
                plot_preambleFFT(PacketPositions,Packet,LongPreambleStart);
                plot_constellations(PacketPositions,OFDMSymbols,SignalFieldPackets); 
                plot_InputAndPreambleCorrelation();
                plot_InputAndPackets(PacketPositions,LongPreambleStart,...
                             Packet,OFDMSymbols, SignalFieldPackets,DataPackets);
                plot_pwelch();
            end
        end    
     
 end
    
end
    