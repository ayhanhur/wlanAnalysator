function plot_InputAndPackets(PacketPositions,LongPreambleStart,...
                             Packet,OFDMSymbols, SignalFieldPackets,DataPackets)
 
 global plots
 
 global LengthLongPreamble
 global LengthShortPreamble
 global OverallSymbolLength
 global ft
 
 d = plots.signal;
 CoarseCFO = plots.CoarseCFO;
 FineCFO   = plots.FineCFO;
 SignalFieldEVM   = plots.SignalFieldEVM;
 


h=figure('Name','Signal','NumberTitle','off');  

%scrsz = get(0,'ScreenSize'); %[left bottom width height]
% newpos=[scrsz(1) scrsz(4)/2-100 scrsz(3) scrsz(4)/2];
% newpos=[25 100 1200 600];%[left bottom width height]
 %set(h,'Position',scrsz);

    hold on;
    plot((1:length(d)),0*abs(d),'k')
    plot((1:length(d)),abs(d),'g') % Hüllkurve Eingangssignal
    title('Hüllkurve Eingangssignal');
    xlabel('Zeit')
    ylabel('Amplitude')

    DMAX=max(abs(d));
    for k=1:length(PacketPositions)
        MPM(k)=mean(abs(Packet{k}(1:LengthShortPreamble))); 
    end
    
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
        
    PacketRateMBit(k)=SignalFieldPackets{k}.Rate;
    PacketLength(k)=SignalFieldPackets{k}.Length;
    PacketOK(k)=SignalFieldPackets{k}.PacketOK;
    
   
    
%     All{k}.Data=DataPackets{k}.decData;
       
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
    
    % Für die Plots  die Abstände zwischen den gültigen Paketen besorgen
    PacketGapAfter=0*PacketPositions; 
    for k=1:length(PacketPositions)-1
        if  PacketOK(k+1) && PacketOK(k)
        PacketGapAfter(k)=PacketPositions(k+1)-LengthShortPreamble+LongPreambleStart(k+1) ...
            -( PacketPositions(k)+LengthLongPreamble+LongPreambleStart(k)+OverallSymbolLength*(OFDMSymbols(k)+1) );
        else
        PacketGapAfter(k)=-1;
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
            byte1=dec2hex(DataPackets{k}.decData(1),2);
            us=sprintf('%s1. Byte: %s\n',us,byte1);
            switch DataPackets{k}.decData(1)
                case { hex2dec('D4') }
                    if length(DataPackets{k}.decData)>=10
                        MAC1=[];
                        for kk=5:10
                            MAC1=[ MAC1 dec2hex(DataPackets{k}.decData(kk),2) ' '];
                        end
                        us=sprintf('%s1. MAC: %s\n',us,MAC1);
                    end
                case { hex2dec('88') }
                    if length(DataPackets{k}.decData)>=16
                        MAC1=[]; MAC2=[];
                        for kk=5:10
                            MAC1=[ MAC1 dec2hex(DataPackets{k}.decData(kk),2) ' '];
                        end
                        for kk=11:16
                            MAC2=[ MAC2 dec2hex(DataPackets{k}.decData(kk),2) ' '];
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
