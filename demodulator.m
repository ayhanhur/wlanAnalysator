function bits=demodulator(OFDMSymbol,PacketModulationM,soft_dec)
%% Demodulieren Hard Decision
            modObj = modem.qamdemod('M', PacketModulationM,...
                                    'PhaseOffset',0, 'SymbolOrder','gray', 'OutputType',...
                                    'integer', 'DecisionType','hard decision');
           
            OFDMSymbolCode = demodulate(modObj,conj(OFDMSymbol));  % Demapper
           
            % Aus den Mapper-Zahlen Bits machen. I = MSBs, Q=LSBs
            bits='1' == dec2bin(real(OFDMSymbolCode),log2(PacketModulationM)) ;
            
            bits=bits'; bits=bits(:); % Bits serialisieren
            
            
 %% Soft Decision
 %%%%% soft bits  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin > 2
     
     addpath('./dede');
     [soft_bits_out]  = rx_demodulate(OFDMSymbol,PacketModulationM);
     bits=soft_bits_out';
     
%      coeff=OFDMSymbol';
%     
%     switch PacketModulationM
%         case 2  % BPSK
%             cmessage = real(coeff);
%             
%         case 4  % QPSK
%             coeff = coeff*sqrt(2);
%             cmessage = zeros(1, 2*numCoeff);
%             cmessage(1:2:2*numCoeff) = real(coeff);
%             cmessage(2:2:2*numCoeff) = imag(coeff);
%             
%         case 16  % 16-QAM
%             coeff = coeff * sqrt(10);
%             coeff = [real(coeff); imag(coeff)];
%             cmessage([1 3], :) = coeff;
%             cmessage([2 4], :) = 2-abs(coeff);
%             
%         case 64  % 64-QAM
%             coeff = coeff * sqrt(42);
%             coeff = [real(coeff); imag(coeff)];
%             cmessage = zeros(6, length(coeff));
%             cmessage([1 4], :) = coeff;
%             cmessage([2 5], :) = (4-abs(coeff));
%             cmessage([3 6], :) = (abs(coeff)-abs(coeff-4)-abs(coeff+4)+6);
%             
%         otherwise
%             error('invalid #bits per sc');
%     end
%    bits=reshape(cmessage, 1, [])';
 end
