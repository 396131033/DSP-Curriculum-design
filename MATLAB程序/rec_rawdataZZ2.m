delete(instrfindall);  % ɾ�����пɼ������ض˿�
s = serial('COM6','Parity','none','BaudRate',57600,'DataBits',8,'StopBits',1);  % ���崮��

ESP= tcpip('192.168.43.12', 8086, 'NetworkRole', 'server');
fopen(ESP);

s.BytesAvailableFcnCount = 64; % 512/8=64
s.BytesAvailableFcnMode = 'byte';
s.timeout = 1;
buffer_rawdata = [];
sumA=0;
sumB=0;
j=1;
  Fs=1024; %����Ƶ�� 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ݲ��˲���%%%%%%%%%%%%%%%%%%%%%%%%%%%
wp50=[48 52]/100;
ws50=[49 51]/100;%���λ��50HZ
rp50=3;
rs50=20;
[n50,wn50]=buttord(wp50,ws50,rp50,rs50);
[h50]=butter(n50,wn50,'stop');
figure(50)
freqz(h50,Fs);title('������˹�ݲ��˲�����Ƶ����'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ͨ�˲�%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Fs=1024; %����Ƶ�� 
fp=40;fs=45; %ͨ����ֹƵ�ʣ������ֹƵ�� 
rp=1.4;rs=1.6; %ͨ�������˥�� 
wp=2*pi*fp;ws=2*pi*fs; 
[n,wn]=buttord(wp,ws,rp,rs,'s'); %��s����ȷ��������˹ģ���˲����״κ�3dB ��ֹģ��Ƶ�� 
[z,P,k]=buttap(n); %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ���� 
[bp,ap]=zp2tf(z,P,k); %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ�� 
[bs,as]=lp2lp(bp,ap,wp); %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ�� 
[hs,ws]=freqs(bs,as); %ģ���˲����ķ�Ƶ��Ӧ 
[bz,az]=bilinear(bs,as,Fs); %��ģ���˲���˫���Ա任 
[h1,w1]=freqz(bz,az); %�����˲����ķ�Ƶ��Ӧ 
figure(1)
freqz(bz,az);title('������˹��ͨ�˲�����Ƶ����'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȥ������Ư��%%%%%%%%%%%%%%%%%%%%%%%%%%%
Wp51=4*2/Fs; %ͨ����ֹƵ�� 
Ws51=0.1*2/Fs; %�����ֹƵ�� 
devel=0.005; %ͨ���Ʋ� 
Rp51=20*log10((1+devel)/(1-devel)); %ͨ���Ʋ�ϵ�� 
Rs51=20; %���˥�� 
[N51,Wn51]=ellipord(Wp51,Ws51,Rp51,Rs51,'s'); %����Բ�˲����Ľ״� 
[b51,a51]=ellip(N51,Rp51,Rs51,Wn51,'high'); %����Բ�˲�����ϵ�� 
[hw51,w51]=freqz(b51,a51,512); 
figure(51) 
freqz(b51,a51)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ͨ�˲��õ�B��%%%%%%%%%%%%%%%%%%%%%%%%%%%
wlp=2*pi*14/Fs;wls=2*pi*16/Fs;
wus=2*pi*30/Fs;wup=2*pi*32/Fs;
wc=[(wlp+wls)/2/pi,(wus+wup)/2/pi];
%tr_width(wup-wus);
B=wls-wlp;
M=ceil(12*pi/B)-1;
hn=fir1(M,wc,kaiser(M+1));
wf=0: pi/511 :pi;
HK=freqz(hn,wf);
wHz=wf*511/(2*pi);%ת��ΪHz
figure(6)
subplot (2, 1, 1);
plot(20*log10(abs(HK)));
xlabel('Ƶ��(Hz)');ylabel('����');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ͨ�˲��õ�A��%%%%%%%%%%%%%%%%%%%%%%%%%%%
wlp1=2*pi*8/Fs;wls1=2*pi*10/Fs;
wus1=2*pi*13/Fs;wup1=2*pi*15/Fs;
wc1=[(wlp1+wls1)/2/pi,(wus1+wup1)/2/pi];
%tr_width(wup-wus);
B1=wls1-wlp1;
M1=ceil(12*pi/B1)-1;
hn1=fir1(M1,wc1,kaiser(M1+1));
wf1=0: pi/511 :pi;
HK1=freqz(hn1,wf1);
wHz1=wf1*511/(2*pi);%ת��ΪHz
subplot (2, 1, 2);
plot(20*log10(abs(HK1)));
xlabel('Ƶ��(Hz)');ylabel('����');


N=1024 ;
n=0:N-1; 
try
    fopen(s);  %�򿪴���
catch   % �����ڴ�ʧ�ܣ���ʾ�����ڲ��ɻ�ã���
    msgbox('���ڲ��ɻ�ã�');
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡԭʼ����%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = 1;
while(p == 1)
    value = fread(s,64,'uint8');
    for i =1:length(value)-7
        if value(i) == hex2dec('AA')
            if value(i+1) == hex2dec('AA')
                if value(i+2) == hex2dec('04')
                    if value(i+3) == hex2dec('80')
                        if value(i+4) == hex2dec('02')
                            rawdata = bitor(bitshift(value(i+5),8),value(i+6));
                            if rawdata > 32768
                                rawdata = rawdata-65536;
                            end
                            buffer_rawdata = [buffer_rawdata;rawdata];
                            
                            g=filter(h50,1,buffer_rawdata(:,1));%ȥ����Ƶ
                            result =filter(b51,a51,g); %ȥ������Ư��
                            m=filter(bz,az, result); %��ͨ�˲�

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ʱ��ͼ%%%%%%%%%%%%%%%%%%%%%%%%%%%
 figure(2)                         
 subplot(4,1,1); 
plot(buffer_rawdata(:,1)); 
xlabel('t(s)');ylabel('mv');title('ԭʼ�Ե��źŲ���');grid; 
 subplot(4,1,2); 
plot(m(:,1));
xlabel('t(s)');ylabel('mv');title('��ͨ�˲���ȥ��Ƶ��ȥ����Ư�ƺ��ʱ��ͼ��');grid; 

z=fftfilt(hn,m);% ��ͨ�˲�B��
Y1 = fft (z, Fs); 
subplot (4, 1, 3);
plot(z(:,1));
title ('��ͨ�˲���B���źŵ�ʱ��ͼ');

z1=fftfilt(hn1,m);% ��ͨ�˲�A��
Y2 = fft (z1, Fs); 
subplot (4, 1, 4);
plot(z1(:,1));
title ('��ͨ�˲���A���źŵ�ʱ��ͼ');



 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��Ƶ��ͼ%%%%%%%%%%%%%%%%%%%%%%%%%%%

mf=fft(buffer_rawdata(:,1),N); %����Ƶ�ױ任������Ҷ�任�� 
mag=abs(mf); 
f=(0:length(mf)-1)*Fs/length(mf); %����Ƶ�ʱ任 
figure(3) 
subplot(4,1,1) 
plot(f,mag);axis([0,1500,1,20000]);grid; %����Ƶ��ͼ 
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('�Ե��ź�Ƶ��ͼ'); 

mfa=fft(m,N); %����Ƶ�ױ任������Ҷ�任�� 
maga=abs(mfa); 
fa=(0:length(mfa)-1)*Fs/length(mfa); %����Ƶ�ʱ任 
subplot(4,1,2) 
plot(fa,maga);axis([0,100,0,20000]);grid; %����Ƶ��ͼ 
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('��ͨ�˲���ȥ��Ƶ��ȥ����Ư�ƺ��Ե��ź�Ƶ��ͼ'); 

magab=abs(Y1); 
fab=(0:length(Y1)-1)*Fs/length(Y1); %����Ƶ�ʱ任 
subplot(4,1,3) 
plot(fab,magab);axis([0,100,0,5000]);grid; %����Ƶ��ͼ 
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('��ͨ�˲���B���źŵ�Ƶ��'); 


magaa=abs(Y2); 
faa=(0:length(Y2)-1)*Fs/length(Y2); %����Ƶ�ʱ任 
subplot(4,1,4) 
plot(faa,magaa);axis([0,100,0,5000]);grid; %����Ƶ��ͼ 
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('��ͨ�˲���A���źŵ�Ƶ��'); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��רע��%%%%%%%%%%%%%%%%%%%%%%%%%%%

[r,q]=size(m);
if (r-j)>50
for t=1:50
sumB=z(j,1).^2+sumB;
sumA=z1(j,1).^2+sumA;
j=j+1;
end
a=sumA/sumB;
a=ceil(a);
if a>100
    a=a-50
end
disp(a);

a=a*3+20;
fprintf(ESP,"%d\r\n",a);
sumA=0;
sumB=0;
end                                          
                            
                        end
                    end
                end
            end
        end
    end
    
end