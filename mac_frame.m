function MAC_DATA  = mac_frame(data,decData)

%% MAC FRAME :
%
% Bytes:    2        2             6        6        6           2       6     2      0-2312     4
% +-------------+-------------+--------+--------+--------+------------+------+-----+-----------+-----+
% | Frame Ctrl. + Duration.ID + Addr.1 + Addr.2 + Addr.3 +  Seq Ctrl. + Addr4+ Qos + Payload   + CRC | 
% +-------------+-------------+--------+--------+--------+------------+------+-----+-----------+-----+
%   
%%  Frame Ctrl Field (2Byte= 16Bit)                                         

  b = data(1:16); %Frame Control Field
  %Protokol Version
  MAC_DATA.FrameCtrl.ProtokolVersion = b(1:2); % laut standart b1=0 b2=0

  %% Type
  type     = 2.^[0 1]*b(3:4)+1; 
  type_tab = {'Management', 'Kontrol' ,'Daten' ,'Reserviert'};

  MAC_DATA.FrameCtrl.Type = type_tab{type};
  %disp(['Type: ',type_tab{type}]);
  
  %% Subtype
  subtype = 2.^(0:1:3)* b(5:8)+1; 
  
  subtype_tab = {'Daten','Daten+CF-Ack','Daten+CF-Poll','Daten+CF-Ack+CF-Poll',...
                 'Null-Funktion (keine Daten)','CF-Ack (keine Daten)','CF-Poll (keine Daten)',...
                 'Daten+CF-Ack+CF-Poll (keine Daten)','Reserviert','Reserviert',...
                 'Power Safe PS','RTS','CTS','ACK','CF-End','CF-End+CF-Ack'};      
%   disp(['SubType: ',subtype_tab{subtype}]);
  [str_type,str_subtype]=sub_type(b(3:4),b(5:8)); 
  disp(['Type:  ',str_type,' | ','Subtype:  ',str_subtype]);
%   disp(['Subtype:  ',str_subtype]);
  MAC_DATA.FrameCtrl.Subtype = str_subtype;
  
  %% To DS FromDS
  MAC_DATA.FrameCtrl.ToDS   = b(9);
  MAC_DATA.FrameCtrl.FromDS = b(10);
  to_from     = 2.^[1 0]* b(9:10)+1;
  to_from_tab = {  'Ad1:(RA = DA) Ad2:(TA = SA) Ad3:(BSSID)',...
                   'Ad1:RA = DA  Ad2:TA = BSSID Ad3:SA',...
                   'Ad1:RA = BSSID Ad2:TA = SA  Ad3:DA',...
                   'Ad1:RA Ad2:TA Ad3:DA Ad4:SA'};
              
 disp(['To DS FromDS:  ',to_from_tab{to_from}]);

  
  MAC_DATA.FrameCtrl.MoreFlag = b(11); %1 ---> weitere fragmente der nachricht folgt
  if b(11)==1 
      disp('weitere fragmente der nachricht folgt');
  end
  MAC_DATA.FrameCtrl.Retry    = b(12); %1 ---> wiederholung des gleichen nachricht
  if b(12)==1 
      disp('wiederholung des gleichen nachricht');
  end
  MAC_DATA.FrameCtrl.PwrMgt   = b(13); %1 ---> Stromsparmodus
  MAC_DATA.FrameCtrl.MoreData = b(14); %1 ---> weitere daten folgt
   if b(14)==1 
      disp('...weitere daten folgt');
  end
  MAC_DATA.FrameCtrl.WEP      = b(15); %1 ---> nutzdaten verschlüsselt
  if b(15)==1 
      disp('WEP');
  end
  MAC_DATA.FrameCtrl.Order    = b(16); %1 ---> weiterleitung höhere schichten
  

  if  length(decData) > 5
  %% Duration ID
  DurationID = data(17:32);
  bit15=DurationID(16);
  bit14=DurationID(15);
  bit0_13=DurationID(1:14);
  bit0_14=DurationID(1:15);
  d_ID_0_13= bintodec( bit0_13,14);
  d_ID_0_14= bintodec( bit0_14,15);
  switch bit15
      case 0
          duration = [num2str(d_ID_0_14),' microsec.'];
      case 1
      if bit14==0 && d_ID_0_13==0
          duration = 'CFP';
      end
      if bit14==0 && 1<=d_ID_0_13<=16383
          duration= 'Reserved';
      end 
     if bit14==1 
         if  1<= d_ID_0_13 <=2007
             duration='AID in PS-Poll frames';
         else
             duration='Reserved';
         end
     end
  end
   disp(['Duration : ',duration]);
  
  %% Adress1 Receiver
  Adress1 = data(33:80);
  mac1 = dec2hex(bintodec(Adress1,8));
  mac1 = mac1';
  mac1 = mac1(:)';
  MAC_DATA.Adresse1= mac1;
  disp(['Receiver MAC: ',mac1]);
  
  if length(decData)>14
      %% Adress2 Transmitter
      Adress2 = data(81:128); 
      mac2 = dec2hex(bintodec(Adress2,8));
      mac2 = mac2';
      mac2 = mac2(:)';
      MAC_DATA.Adresse2= mac2;
      disp(['Transmitter MAC: ',mac2]);
  end
  
  if length(decData) > 34
      %% Adress3
      Adress3=data(129:176);
      mac3 = dec2hex(bintodec(Adress3,8));
      mac3 = reshape(mac3',1,[]);
      MAC_DATA.Adresse3= mac3;
      disp(['MAC3: ',mac3]);
      
      %% Sequence Control Field
      SequenceCtrl = data(177:192);
      FragmentNr   = SequenceCtrl(1:4);
      SequenzNr    = SequenceCtrl(5:end);
  
      Fragment= bintodec(FragmentNr,4);
      Sequenz = bintodec(SequenzNr,12);
      strr= ['Fragment: ',num2str(Fragment),' Sequenz: ',num2str(Sequenz)];
      MAC_DATA.SequenceCtrl = strr;
      disp(strr);
     
         if to_from == 4
              %% Payload und Adress4(optional) 
              Adress4 = data(193:240);
              mac4 = dec2hex(bintodec(Adress4,8));
              mac4 = reshape(mac4',1,[]);
              MAC_DATA.Adresse4 = mac4;
              disp(['MAC4: ',mac4]);
              if strfind(str_subtype,'QoS')
              payload  = data(257:end-32);
              else
                  payload  = data(241:end-32);
              end
         else
             payload = data(193:end-32);
         end  
         MAC_DATA.FrameBody = bintodec(payload,8)';
         disp(['Frame Body: ',num2str(length(payload)/8),' Byte']);
       
  end
  else
      display('no MAC Info !');
  end
  