function plot_PacketFinds(PacketPositions,LongPreambleStart,Packet,OFDMSymbols,SignalFieldPackets)

%---------------------------------------------------
%
%
%--------------------------------------------------
global LengthShortPreamble
global LengthLongPreamble
global MinimumPacketSize
global OverallSymbolLength

global plots
crcError  = plots.crcError;
d = plots.signal;
SignalFieldEVM   = plots.SignalFieldEVM;

PacketParityOK  = plots.PacketParityOK ;
PacketTrailerOK = plots.PacketTrailerOK ;

    P = ceil(sqrt(length(PacketPositions)));
    P2= ceil(length(PacketPositions)/P);
    
    h=figure('Name','Alle Pakete','NumberTitle','off');
 %    scrsz = get(0,'ScreenSize'); %[left bottom width height]
%     newpos=[25 100 800 600];%[left bottom width height]
  %   set(h,'Position',scrsz)

    PS = max(max(abs(real(d)),max(abs(imag(d)))));
    
    for k=1:length(PacketPositions)
    
    PacketRateMBit = SignalFieldPackets{k}.Rate;
    PacketLength   = SignalFieldPackets{k}.Length;
    PacketOK       = SignalFieldPackets{k}.PacketOK;
    RateIndex         = SignalFieldPackets{k}.RateIndex;
    
        subb(k)=subplot(P,P2,k);
        %title([num2str(k),'.Paket'],'color','b')
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
        if(PacketOK >0)
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

%         ok='OK'; col='black'; if (0==PacketParityOK(k));  ok='not OK'; col='red'; end
%         if PacketRateMBit ==0 ; col='red'; end
%         fd=sprintf('%d MBit/s %d Bytes Parity %s',PacketRateMBit,PacketLength,ok);
%         text(10,0.8*PS,fd,'HorizontalAlignment','left','color',col,'FontSize',9)

pok='OK'; tok=pok;cok=pok; col='black';
        if (0==PacketParityOK(k)) ;pok='not OK'; col='red'; end
        if (0==PacketTrailerOK(k)) ;tok='not OK'; col='red'; end
        if ~isempty(crcError)
        if (1==crcError{k}) ;cok='Error';col='y'; end
        end
        
        if PacketOK
        fd=sprintf('%d.Paket\n%d MBit/s %d Bytes CRC.%s\nPar. %s Trail. %s EVM %1.2f ',k,PacketRateMBit,PacketLength,cok,pok,tok,SignalFieldEVM(k));
        else
            fd=sprintf('%d.Paket\n%d MBit/s %d Bytes \nPar. %s Trail. %s EVM %1.2f ',k,PacketRateMBit,PacketLength,pok,tok,SignalFieldEVM(k));
        end
        title(fd,'color',col,'FontSize',9)
        
        if OFDMSymbols(k)==0 
            if RateIndex==9
              text(10,0.8*PS,'Illegal Datarate!','color','r');
            else
            text(10,0.8*PS,'Packet nOK!','color','r');
            end
        end
        hold off
    end
set(gcf, 'WindowButtonDownFcn', {@plot_sub,subb});
  