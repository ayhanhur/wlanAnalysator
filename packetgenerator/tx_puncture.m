
function punctured_bits = tx_puncture(in_bits, code_rate)

% puncturing
if code_rate ~= 1/2
 switch code_rate
   case 3/4
   % R=3/4, Puncture pattern: [1 2 3 x x 6], x = punctured 
   punc_patt=[1 2 3 6];
   punc_patt_size = 6;
   case 2/3
   % R=2/3, Puncture pattern: [1 2 3 x], x = punctured 
   punc_patt=[1 2 3]; 
   punc_patt_size = 4;
   case 1/2
   % R=1/2, Puncture pattern: [1 2 3 4 5 6], x = punctured 
   punc_patt=[1 2 3 4 5 6];
   punc_patt_size = 6;
   otherwise
   error('Undefined convolutional code rate');
 end
end


% Remainder bits are the bits in the end of the packet that are not integer multiple of the puncture window size
num_rem_bits = rem(length(in_bits), punc_patt_size);

puncture_table = reshape(in_bits(1:length(in_bits)-num_rem_bits), punc_patt_size, fix(length(in_bits)/punc_patt_size));
tx_table = puncture_table(punc_patt,:);

%puncture the remainder bits
rem_bits = in_bits(length(in_bits)-num_rem_bits+1:length(in_bits));
rem_punc_patt = find(punc_patt<=num_rem_bits);
rem_punc_bits = rem_bits(rem_punc_patt)';

punctured_bits = [tx_table(:)' rem_punc_bits];

