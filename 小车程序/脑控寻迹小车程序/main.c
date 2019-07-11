#include "stm32f10x.h"
#include "interface.h"
#include "IRCtrol.h"
#include "motor.h"
#include "uart.h"

//ȫ�ֱ�������
unsigned int speed_count=0;//ռ�ձȼ����� 50��һ����
char front_left_speed_duty=SPEED_DUTY;
char front_right_speed_duty=SPEED_DUTY;
char behind_left_speed_duty=SPEED_DUTY;
char behind_right_speed_duty=SPEED_DUTY;


unsigned char tick_5ms = 0;//5ms����������Ϊ�������Ļ�������
unsigned char tick_1ms = 0;//1ms����������Ϊ����Ļ���������
unsigned char tick_200ms = 0;//ˢ����ʾ

char ctrl_comm = COMM_STOP;//����ָ��
char ctrl_comm_last = COMM_STOP;//��һ�ε�ָ��
unsigned char continue_time=0;


//ѭ����ͨ���ж��������Թܵ�״̬������С���˶�
void SearchRun(void)
{
	//��·����⵽
	if(SEARCH_M_IO == BLACK_AREA && SEARCH_L_IO == BLACK_AREA && SEARCH_R_IO == BLACK_AREA)
	{
		ctrl_comm = COMM_UP;
		return;
	}
	
	if(SEARCH_R_IO == BLACK_AREA)//��
	{
		ctrl_comm = COMM_RIGHT;
	}
	else if(SEARCH_L_IO == BLACK_AREA)//��
	{
		ctrl_comm = COMM_LEFT;
	}
	else if(SEARCH_M_IO == BLACK_AREA)//��
	{
		ctrl_comm = COMM_UP;
	}
}


int main(void)
{
	u16 t;  
	u16 len;
	delay_init();
	GPIOCLKInit();
	UserLEDInit();
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2); //����NVIC�жϷ���2:2λ��ռ���ȼ���2λ��Ӧ���ȼ�
	uart_init(115200);	 //���ڳ�ʼ��Ϊ115200
	TIM2_Init();
	MotorInit();
	CarGo();
	Delayms(200);
	CarStop();

	

	CarGo();
	Delayms(200); 
	CarStop();
	Delayms(10000); 
	printf("\r\nI`m ready\r\n\r\n");
	USART_RX_STA = 0;	
	attention = 0;
  
while(1)
{	 
	
	if(USART_RX_STA&0x8000)
	{
		CarStop();
		//0011 1111 1111 1111
		len=USART_RX_STA&0x3fff;//�õ��˴ν��յ������ݳ���
		//��ȡרע��
		for(t=0;t<len;t++)
			{
				//��ȡ8λ�еĵ���λ
				int low;
				low = (USART_RX_BUF[t] & 0x0f);
				//�����һλ����רע�Ⱦ������ֱ���
				if (len == 1) {
					attention =low;
				//�������λ����רע�Ⱦ��Ǹ���λ*10 + ����λ
				}else if (len == 2) {
					if (t == 0) {
						attention =low * 10;
					}else {
						attention +=low;
					}
				}
			}
		printf("%d\n\r\n",attention);
		printf("\r\nI did it\n\r\n");

		USART_RX_STA=0;
		CarGo();
		//Delayms(5000); 
	}else
	{
		SearchRun();
		if(ctrl_comm_last != ctrl_comm)//ָ����仯
		{
			ctrl_comm_last = ctrl_comm;
			switch(ctrl_comm)
			{
				case COMM_UP:    CarGo();break;
				case COMM_DOWN:  CarBack();break;
				case COMM_LEFT:  CarLeft();break;
				case COMM_RIGHT: CarRight();break;
				case COMM_STOP:  CarStop();break;
				default : break;
			}
			Delayms(10);//����
		}
	}
	


 }
}

