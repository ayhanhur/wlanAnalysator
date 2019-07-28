function data=descrambler(decoded)

%% Descrambling
        % Descrambler erstmal initialisieren
        g=decoded(7:-1:1);  
        scr=g;           % Anfängliche Sequenz = 7 Bit der Eingangsfolge
        
        % PRN für die Restlichen ausrechenen
        for i=1:length(decoded)-7;   
            g=[ mod(g(7)+g(4),2) ; g(1:6)];  % Das ist das Polynom
            scr= [ scr ; g(1) ];  % Ein Bit zur PRN dazu
        end
        data=mod(scr+decoded,2);  % descamblen