
global neurosky_scom

neurosky_Port = 'COM4';
neurosky_scom = serial(char(neurosky_Port));
%% ���ô������ԣ�ָ����ص�����
%BaudRate ������
%Parity ����λ
%BytesAvailableFcnCount ��ȡָ���ֽ��������жϺ���
%BytesAvailableFcnMode �жϴ����¼�Ϊ��bytes-aviliable Event��
%BytesAvailableFcn ���ûص�����������neurosky_scomд��ص�����
%Terminator ��ֹ��Ϊ CR(�س�) LF�����У�    'Terminator','CR/LF',...
%timeout ����һ�ζ�д����������ʱ��
set(neurosky_scom, 'BaudRate', 57600,...
    'Parity', 'none',...
    'BytesAvailableFcnCount', 288,...
    'BytesAvailableFcnMode', 'byte',...
    'BytesAvailableFcn', @CallBackNeuroskyCom,...  
    'timeout',1); 

try
    fopen(neurosky_scom);  %�򿪴���
catch   % �����ڴ�ʧ�ܣ���ʾ�����ڲ��ɻ�ã���
    msgbox('���ڲ��ɻ�ã�');
    return;
end




