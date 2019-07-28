function decData=bintodec(binData,dim)

%b_0 b_1 ..  b_n ---> (LSB-->b_0*2^0)+...+(MSB-->b_n*2^n)
% 

if mod(length(binData), dim) ~= 0
    error('Länge der Daten und Dimension müssen übereinstimmen!');
end

        binData=reshape(binData,dim,length(binData)/dim);
        
        for i=1:size(binData,2)
            
            decData(i)=sum(binData(:,i).*(2.^[0:(dim-1)])');
            
        end
               