function decData=bintodec(binData,dim,opt)

% default LSB erste Bit
if nargin>2
    if strcmpi(opt, 'msb')
       k=(dim-1):-1:0;
    else
       k=0:1:dim-1;
    end
else
    k=0:1:dim-1;
end

if mod(length(binData), dim) ~= 0
    error('Länge der Daten und Dimension müssen übereinstimmen!');
end

        binData=reshape(binData,dim,length(binData)/dim);
        
        for i=1:size(binData,2)
            
            decData(i)=sum(binData(:,i).*(2.^k)');
            
        end
               