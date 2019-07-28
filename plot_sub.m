
  function plot_sub(src,evnt,s)
      
      fig_name=get(src,'Name');
      set(src,'Units','normalized');
      curr=get(src,'CurrentPoint');
      %get(s(1),'Position');
      for i=1:length(s)
      sub_pos=get(s(i),'Position');
      
      check =(curr(1)>=sub_pos(1) && curr(1)<= (sub_pos(1)+sub_pos(3))) && ...
             (curr(2) >= sub_pos(2) && curr(2) <= (sub_pos(2)+sub_pos(4)));
         
         if check
             figure;
         new_handle = copyobj(s(i),gcf);
         set(gca,'Position',[0.1300    0.1100    0.7750    0.75])
         if strcmp(fig_name, 'Alle Pakete')
             ylabel('Amplitude')
             xlabel('Abtastwerte');
             legend('Real','Imaginär','Grenzen')
         end
         if strcmp(fig_name, 'Konstellation Diagramme Signal Feld') || strcmp(fig_name, 'Konstellation Diagramme Daten Feld')
         ylabel('Q');
         xlabel('I')
         grid on;
         end
         end
      end    
 
  
 