function plot_preambleFFT(PacketPositions,Packet,LongPreambleStart)

global SymbolLength
global OverallSymbolLength
global SymbolLength

    figure('Name','preambleFFT','NumberTitle','off')
    for k=1:length(PacketPositions)
        
        sp(1)=subplot(3,1,1);
        plot([-32:31],abs(fftshift(fft(Packet{k}(1+0*LongPreambleStart(k)+(0:SymbolLength-1))))))
        ylabel('|Y_{k}|');
        xlabel('Unterträger');
        title('Short Preamble')
        hold on;

         sp(2)=subplot(3,1,2);
        plot([-32:31],abs(fftshift(fft(Packet{k}(LongPreambleStart(k)+(0:SymbolLength-1))))))
        ylabel('|Y_{k}|');
        xlabel('Unterträger');
        title('Long Preamble L1')
        hold on;
 
        sp(3)=subplot(3,1,3);
        plot([-32:31],abs(fftshift(fft(Packet{k}(LongPreambleStart(k)+OverallSymbolLength+(0:SymbolLength-1))))));
        ylabel('|Y_{k}|');
        xlabel('Unterträger');
        title('Long Preamble L2')
        hold on;
        
    end
    set(gcf, 'WindowButtonDownFcn', {@plot_sub,sp});
    
    figure;
    
    for k=1:length(PacketPositions)        
        fft1(k,:)=abs(fftshift(fft(Packet{k}(1+0*LongPreambleStart(k)+(0:SymbolLength-1)))));
        plot3([-32:31],k*ones(64,1),fft1(k,:));
        zlabel('|Y_{k}|');
        xlabel('Unterträger');
        ylabel('Paket Nummer')
        title('Short Preamble')
        hold on;
    end
    
  
    figure;
    for k=1:length(PacketPositions)  
        fft2(k,:)=abs(fftshift(fft(Packet{k}(LongPreambleStart(k)+(0:SymbolLength-1)))));
        plot3([-32:31],k*ones(64,1),fft2(k,:));
        zlabel('|Y_{k}|');
        xlabel('Unterträger');
        ylabel('Paket Nummer')
        title('Long Preamble L1')
        hold on;
    end
    
    
    figure;
    for k=1:length(PacketPositions)    
        fft3(k,:)=abs(fftshift(fft(Packet{k}(LongPreambleStart(k)+OverallSymbolLength+(0:SymbolLength-1)))));
        plot3([-32:31],k*ones(64,1),fft3(k,:));
        title('Long Preamble L2')
        zlabel('|Y_{k}|');
        xlabel('Unterträger');
        ylabel('Paket Nummer')
        hold on;
    end
    
%    figure;
%    bar3(fft1)
%    axis([ -32 31  0 length(PacketPositions) 0 1]) 
%    figure;
%    bar3(fft2)
%    figure;
%    bar3(fft3)
