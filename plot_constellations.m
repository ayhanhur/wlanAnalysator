
function plot_constellations(PacketPositions,OFDMSymbols,SignalFieldPackets)

global plots

PacketOFDMSymbol = plots.PacketOFDMSymbol;
SignalFieldEVM   = plots.SignalFieldEVM;
PacketAngle      = plots.PacketAngle;
PacketPilot      = plots.PacketPilot;
PacketParityOK   = plots.PacketParityOK;
PacketTrailerOK  = plots.PacketTrailerOK;
crcError         = plots.crcError;
SignalFieldPlot  = plots.SignalFieldPlot;


    P=ceil(sqrt(length(PacketPositions)));
    P2=ceil(length(PacketPositions)/P);

%% Constellation Signal Field

    h1=figure('Name','Konstellation Diagramme Signal Feld','NumberTitle','off');
 %   scrsz = get(0,'ScreenSize'); %[left bottom width height]
%     newpos=[25 100 800 600];%[left bottom width height]
  %   set(h1,'Position',scrsz)

    for k=1:length(PacketPositions)
        
        %%Packet Merkmale laden
        PacketLength      = SignalFieldPackets{k}.Length;
        PacketRateMBit    = SignalFieldPackets{k}.Rate;
        PacketOK          = SignalFieldPackets{k}.PacketOK;
        
        s(k)=subplot(P,P2,k);
        title([num2str(k),'.Paket'],'color','b')
        ylabel('Q');
         xlabel('I');
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
            plot(clipit(real(SignalFieldPlot{k}(kk)),2)+j*clipit(imag(SignalFieldPlot{k}(kk)),2),'o','MarkerEdgeColor',col);
        end
        
        pok='OK'; tok=pok; cok=pok; col='black';
        if (0==PacketParityOK(k)) ;pok='not OK'; col='red'; end
        if (0==PacketTrailerOK(k)) ;tok='not OK'; col='red'; end
        
        if ~isempty(crcError) 
        if (1==crcError{k})  ;cok='Error'; col='y';  end
        end
        
        if PacketOK
        fd=sprintf('%d.Paket\n%d MBit/s %d Bytes CRC.%s\nPar. %s Trail. %s EVM %1.2f ',k,PacketRateMBit,PacketLength,cok,pok,tok,SignalFieldEVM(k));
        else
            fd=sprintf('%d.Paket\n%d MBit/s %d Bytes \nPar. %s Trail. %s EVM %1.2f ',k,PacketRateMBit,PacketLength,pok,tok,SignalFieldEVM(k));
        end
        title(fd,'color',col,'FontSize',9)
        hold off
    end

set(gcf, 'WindowButtonDownFcn', {@plot_sub,s});

    %% Constellation Data Field

    h2=figure('Name','Konstellation Diagramme Daten Feld','NumberTitle','off');
 %  scrsz = get(0,'ScreenSize'); %[left bottom width height]
%     newpos=[25 100 800 600];%[left bottom width height]
%    set(h2,'Position',scrsz)
%     
    for k=1:length(PacketPositions)
    
        %%Packet Merkmale laden
        PacketLength      = SignalFieldPackets{k}.Length;
        PacketRateMBit    = SignalFieldPackets{k}.Rate;
        PacketModulationM = SignalFieldPackets{k}.Modulation;
        RateIndex         = SignalFieldPackets{k}.RateIndex;
        PacketOK          = SignalFieldPackets{k}.PacketOK;
       
        
        sb(k)=subplot(P,P2,k);
        
        hold on;

        SizeTab=[ 2 2 4 4 6 6 10 10 8 ]; 

        Siz=SizeTab(RateIndex);

        axis([ -Siz Siz -Siz Siz ]);

        


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
                

                for i=-(max(2,sqrt(PacketModulationM))-2):2:(max(2,sqrt(PacketModulationM))-2)
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
        ylabel('Q');
         xlabel('I');
        %xlabel(fd,'color',col)
        
        if OFDMSymbols(k)==0 
            if RateIndex==9
              text(0,0,'Illegal Datarate!','color','r');
            else
            text(0,0,'Packet nOK!','color','r');
            end
        end
    end
set(gcf, 'WindowButtonDownFcn', {@plot_sub,sb});

