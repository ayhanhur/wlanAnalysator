function const_dia(Mod)

% tabM=[64 16 4 2];
% ind=find(tabM==Mod);
% tab=[7 3 1 1];
% bit=[6 4 2 1];
% m=tab(ind);
% 
% symbols=[];
% dim=[-m:2:m];
% 
% x=0:1:M-1;
% [y,map] = gray2bin(x,'qam',Mod);
% 
% for i=1:length(dim)
% symbols(length(symbols)+1:length(symbols)+8)=dim(i)+ j*dim;
% end
% 
% scatterplot(symbols);
% %  set(get(gca,'Children'),'Marker','d','MarkerFaceColor','auto');
% %  hold on;
% 
% for jj=1:M
%   text(real(symbols(jj))-0.15,imag(symbols(jj))+0.15,dec2base(map(jj),2,6),'FontSize',8);
% end
% title('64-QAM                              (b_0 b_1 b_2 b_3 b_4 b_5)') 
% 
%  set(gca,'yTick',(-8:2:8),'xTick',(-8:2:8),...
%   'XLim',[-10 10 ],'YLim',...
%    [-10 10],'Box','on','YGrid','on', 'XGrid','on');
% 
% line([0 0],[10 -10])
% line([10 -10],[0 0])


symbols=[];
dim=[-3:2:3];

x=0:3;
[y,map] = gray2bin(x,'qam',16);

for i=1:length(dim)
symbols(length(symbols)+1:length(symbols)+4)=dim(i)+ j*dim;
end


scatterplot(symbols);
set(gca,'yTick',(-4:2:4),'xTick',(-4:2:4),...
  'XLim',[-4 4 ],'YLim',...
   [-4 4],'Box','on','YGrid','on', 'XGrid','on');
title('16-QAM                              (b_0 b_1 b_2 b_3)') 
line([0 0],[4 -4])
line([4 -4],[0 0])

for jj=1:16
  text(real(symbols(jj))-0.3,imag(symbols(jj))+0.3,dec2base(map(jj),2,4),'FontSize',8);
end

