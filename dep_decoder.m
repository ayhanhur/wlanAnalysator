function decoded=dep_decoder(bits,index,soft_dec)
global trellis
%% Depunktierung 
        switch index
            
            case { 2,4,6,8 }
                
                ppat= [  1 1 1 0 0 1  ]; % restliche Modes Mit Punktierung
                
            case 7
                
                ppat=[ 1 1 1 0 ]; % 48 Mbit-Mode
                
            otherwise    % R=1/2, kein Punktierung
        end
        
 
      
   %%   Decodierung Hard Decision  
   
        switch index % Viterbi-Decoder mit oder ohne Punktierung
            
            case { 2,4,6,7,8 }
                
                decoded = vitdec([ bits ] ,trellis,48/2,'trunc','hard',ppat ) ;
                
            otherwise
                
                decoded=vitdec([ bits ] ,trellis,48/2,'trunc','hard');
        end
        
   if nargin>2
      %%  Decodierung Soft Decision
      
      switch index % Viterbi-Decoder mit oder ohne Punktierung
            
            case { 2,4,6,7,8 }
                
                decoded = vitdec([ bits ] ,trellis,48/2,'trunc','soft',ppat ) ;
                
            otherwise
                
                decoded=vitdec([ bits ] ,trellis,48/2,'trunc','soft');
        end
        
  
  
  end 
