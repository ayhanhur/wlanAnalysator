function [out1,out]=sub_type(typ,sub)
%802.11a Subtype

type=bintodec(typ,2);
%type = 2.^[1 0]*typ;
subtype=bintodec(sub,4);
%subtype = 2.^(3:-1:0)*sub;

if type==0
    %Management b3=0b2=0
    out1= 'Management';
switch subtype
case 0
out= 'Association request';
case 1
out= 'Association response';
case 2
out= 'Reassociation request';
case 3
out= 'Reassociation response';
case 4
out= '0100 Probe request';
case 5
out= 'Probe response';
case 8
out= 'Beacon';
case 9
out= 'ATIM';
case 10
out= '1010 Disassociation';
case 11
out= 'Authentication';
case 12
out= 'Deauthentication';
case 13
out= 'Action';
otherwise 
out= 'Reserved';
end

%Control b3=0 b2=1
elseif type==1
    out1= 'Kontrol';
switch subtype %b7 b6 b5 b4
case 8
out= 'Block Ack Request (BlockAckReq)';
case 9
out= 'Block Ack (BlockAck)';
case 10
out= 'PS-Poll';
case 11
out= 'RTS';
case 12
out= 'CTS';
case 13
out= 'ACK';
case 14
out= 'CF-End';
case 15
out= 'CF-End + CF-Ack';
otherwise
    out= 'Reserved';
end

%Daten b3=1 b2=0
elseif type==2
    out1= 'Daten';
switch subtype
    case 0
    out= 'Data';
    case 1
        out= 'Data + CF-Ack';
    case 2
        out= 'Data + CF-Poll';
    case 3
        out= 'Data + CF-Ack + CF-Poll';
    case 4
        out= 'Null (no data)';
    case 5
        out= 'CF-Ack (no data)';
    case 6
        out= 'CF-Poll (no data)';
    case 7
        out= 'CF-Ack + CF-Poll (no data)';
    case 8
        out= 'QoS Data';
    case 9
        out= 'QoS Data + CF-Ack';
    case 10
        out= 'QoS Data + CF-Poll';
    case 11
        out= 'QoS Data + CF-Ack + CF-Poll';
    case 12
        out= 'QoS Null (no data)';
    case 13
        out= 'Reserved';
    case 14
        out= 'QoS CF-Poll (no data)';
    case 15
        out= 'QoS CF-Ack + CF-Poll (no data)';
    otherwise   
        out= 'Reserved';
end
else 
    out='Reserved';
     out1= 'Reserved';
end

% disp('Type:  ',out1);
%  disp('Subtype:  ',out);