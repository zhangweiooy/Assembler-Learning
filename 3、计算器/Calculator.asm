.386
.model flat,stdcall
option casemap:none

include  windows.inc
include  shell32.inc
include  user32.inc
include  comctl32.inc
include  masm32.inc
include  kernel32.inc

includelib  user32.lib
includelib  comctl32.lib
includelib  masm32.lib
includelib  kernel32.lib
includelib  shell32.lib
includelib  msvcrt.lib

fopen	proto c:dword,:dword
fgets	proto c:dword,:dword,:dword
fclose  proto c:dword
strcmp	proto c:dword,:dword
strlen	proto c:dword
strcat  proto c:dword,:dword
_itoa	proto c:dword,:dword,:dword
MessageBoxA proto :DWORD, :DWORD, :DWORD, :DWORD 
MessageBox 	equ   <MessageBoxA>

.data
num dword 0
num1 dq 0.0
num2 dq 0.0
hInstance dd ?  ;存放应用程序的句柄
hWinMain dd ?   ;存放窗口的句柄
showButton byte 'Click to start',0
button db 'button',0
titleAlert byte 'Alert',0
noDivide byte 'The division is 0',0 
buf1 byte 1024 dup(0)
buf2 byte 1024 dup(0)
len dd 0
operator dword ?
display byte '0',0
static byte 'static',0
bu0 byte '0',0
bu1 byte '1',0
bu2 byte '2',0
bu3 byte '3',0
bu4 byte '4',0
bu5 byte '5',0
bu6 byte '6',0
bu7 byte '7',0
bu8 byte '8',0
bu9 byte '9',0
buDot byte '.',0
buMul byte '*',0
buDiv byte '/',0
buSub byte '-',0
buA byte '+',0
buE byte '=',0
buAC byte 'AC',0
cos byte 'cos',0
sin byte 'sin',0
tan byte 'tan',0
equal dword 0
divisionIsZero dword 1

.const
szClassName db 'MyClass',0
szCaptionMain db 'Calculator',0
szText db ' ',0
zero dq 0.0

.code
_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  ;窗口过程
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hDc

	mov eax,uMsg  ;uMsg是消息类型，如下面的WM_PAINT,WM_CREATE

	.if eax==WM_PAINT  ;如果想自己绘制客户区，在这里些代码，即第一次打开窗口会显示什么信息
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax

		invoke GetClientRect,hWnd,addr @stRect
		invoke DrawText,@hDc,addr szText,-1,addr @stRect,DT_SINGLELINE or DT_CENTER or DT_VCENTER  ;这里将显示szText里的字符串
		invoke EndPaint,hWnd,addr @stPs
	
	.elseif eax==WM_CLOSE  ;窗口关闭消息
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL

	.elseif eax==WM_CREATE  ;创建窗口  下面代码表示创建一个按钮，其中button字符串值是'button'，在数据段定义，表示要创建的是一个按钮，showButton表示该按钮上的显示信息
		invoke CreateWindowEx,NULL,offset button,offset buE,WS_CHILD or WS_VISIBLE,265,70,60,60,hWnd,10,hInstance,NULL  ;EQU 10
		invoke CreateWindowEx,NULL,offset button,offset bu1,WS_CHILD or WS_VISIBLE,5,70,60,60,hWnd,1,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset bu2,WS_CHILD or WS_VISIBLE,70,70,60,60,hWnd,2,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset bu3,WS_CHILD or WS_VISIBLE,135,70,60,60,hWnd,3,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset buA,WS_CHILD or WS_VISIBLE,200,70,60,60,hWnd,11,hInstance,NULL ;ADD 11
		invoke CreateWindowEx,NULL,offset button,offset bu4,WS_CHILD or WS_VISIBLE,5,135,60,60,hWnd,4,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset bu5,WS_CHILD or WS_VISIBLE,70,135,60,60,hWnd,5,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset bu6,WS_CHILD or WS_VISIBLE,135,135,60,60,hWnd,6,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset buSub,WS_CHILD or WS_VISIBLE,200,135,60,60,hWnd,12,hInstance,NULL ;SUB 12
		invoke CreateWindowEx,NULL,offset button,offset cos,WS_CHILD or WS_VISIBLE,265,135,60,60,hWnd,13,hInstance,NULL ;COS 13
		invoke CreateWindowEx,NULL,offset button,offset bu7,WS_CHILD or WS_VISIBLE,5,200,60,60,hWnd,7,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset bu8,WS_CHILD or WS_VISIBLE,70,200,60,60,hWnd,8,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset bu9,WS_CHILD or WS_VISIBLE,135,200,60,60,hWnd,9,hInstance,NULL
		invoke CreateWindowEx,NULL,offset button,offset buMul,WS_CHILD or WS_VISIBLE,200,200,60,60,hWnd,14,hInstance,NULL  ;MUL 14
		invoke CreateWindowEx,NULL,offset button,offset sin,WS_CHILD or WS_VISIBLE,265,200,60,60,hWnd,15,hInstance,NULL ;SIN 15
		invoke CreateWindowEx,NULL,offset button,offset buAC,WS_CHILD or WS_VISIBLE,5,265,60,60,hWnd,16,hInstance,NULL ;AC 16
		invoke CreateWindowEx,NULL,offset button,offset bu0,WS_CHILD or WS_VISIBLE,70,265,60,60,hWnd,0,hInstance,NULL 
		invoke CreateWindowEx,NULL,offset button,offset buDot,WS_CHILD or WS_VISIBLE,135,265,60,60,hWnd,17,hInstance,NULL ;DO 17
		invoke CreateWindowEx,NULL,offset button,offset buDiv,WS_CHILD or WS_VISIBLE,200,265,60,60,hWnd,18,hInstance,NULL ;DIV 18
		invoke CreateWindowEx,NULL,offset button,offset tan,WS_CHILD or WS_VISIBLE,265,265,60,60,hWnd,19,hInstance,NULL ;tan 19
		invoke CreateWindowEx,NULL,offset static,offset display,WS_CHILD or WS_VISIBLE or ES_RIGHT,5,5,320,60,hWnd,20,hInstance,NULL ;DIS 20
	.elseif eax==WM_COMMAND
		mov eax,wParam
		.if (eax >=0 && eax <=9) || eax == 17 
			.if eax >= 0 && eax <= 9
				add eax,48
			.elseif eax == 17
				mov eax,46
			.endif
			.if equal == 1
				finit
				mov ebx,0
				mov equal,ebx
				mov num,ebx
				xor cl,cl
				.while ebx < 1024
					mov buf1[ebx],cl
					inc ebx
				.endw
				jmp L4
			.endif
			.if num==0
			L4:
				mov ecx,len
				inc len
				mov buf1[ecx],al
				invoke SetDlgItemText,hWnd,20,addr buf1
			.else
				mov ecx,len
				inc len
				mov buf2[ecx],al
				push eax
				invoke SetDlgItemText,hWnd,20,addr buf2
				pop eax
				.if al !=48 && al != 46
					mov eax,0
					mov divisionIsZero,eax
				.endif
			.endif
		.elseif eax != 16 && eax != 20
			push eax
			mov eax,0
			mov len,eax
			.if equal == 1
				xor eax,eax
				mov equal,eax
				jmp L0
			.endif
			.if num==0
				inc num
				invoke StrToFloat,addr buf1,addr num1
				mov eax,0
				mov ebx,0
				.while eax < 1024
					mov buf1[eax],bl
					inc eax
				.endw
			.else
				inc num
				invoke StrToFloat,addr buf2,addr num2
				mov eax,0
				mov ebx,0
				.while eax<1024
					mov buf2[eax],bl
					inc eax
				.endw
			.endif
		L0:
			pop eax
			mov ecx,operator
			mov ebx,num
			.if ebx == 1
				.if eax == 10
					xor eax,eax
					mov operator,eax
					invoke FloatToStr,num1,addr buf1
					invoke SetDlgItemText,hWnd,20,addr buf1
					mov eax,1
					mov equal,eax
					ret
				.endif
				fld num1
				.if eax == 13 || eax == 15 || eax == 19
					.if eax == 13
						FCOS
					.elseif eax == 15
						FSIN
					.else
						FPTAn
					.endif
					fst num1
					invoke FloatToStr,num1,addr buf1
					invoke SetDlgItemText,hWnd,20,addr buf1
					xor eax,eax
					mov num,eax
					finit
					ret
				.endif
				mov operator,eax
			.elseif ebx == 2
				push eax
				.if eax == 13 || eax ==15 || eax ==19
					pop eax
					fld num2
					.if eax == 13
						FCOS
					.elseif eax == 15
						FSIN
					.else
						FPTAn
					.endif
					fstp num2
					invoke FloatToStr,num2,addr buf2
					invoke SetDlgItemText,hWnd,20,addr buf2
					fstp num1
					invoke FloatToStr,num1,addr buf1
					mov eax,1
					mov num,eax
					finit
					fld num1
					ret
				.elseif ecx == 11
					fld num2
					fadd
					fst num1
					invoke FloatToStr,num1,addr buf1
					invoke SetDlgItemText,hWnd,20,addr buf1
					mov eax,1
					mov num,eax
					jmp L8
				.elseif ecx == 12
					fld num2
					fsub
					fst num1
					invoke FloatToStr,num1,addr buf1
					invoke SetDlgItemText,hWnd,20,addr buf1
					mov eax,1
					mov num,eax
					jmp L8
				.elseif ecx == 14
					fld num2
					fmul
					fst num1
					invoke FloatToStr,num1,addr buf1
					invoke SetDlgItemText,hWnd,20,addr buf1
					mov eax,1
					mov num,eax
					jmp L8
				.elseif ecx == 18
					fld num2
					.if divisionIsZero == 1
						invoke MessageBox,hWnd,offset noDivide,offset titleAlert,MB_OK
						pop eax
						jmp L3
					.endif
					mov eax,1
					mov divisionIsZero,eax
					fdiv
					fst num1
					invoke FloatToStr,num1,addr buf1
					invoke SetDlgItemText,hWnd,20,addr buf1
					mov eax,1
					mov num,eax
					jmp L8
				.else
				L8:
					pop eax
					.if eax == 10
						xor eax,eax
						mov operator,eax
						mov eax,1
						mov equal,eax
						ret
					.endif
					mov operator,eax
				.endif
			.endif
		.elseif eax == 16
		L3:
			mov eax,0
			mov ebx,0
			.while eax <1024
				mov buf1[eax],bl
				mov buf2[eax],bl
				inc eax
			.endw
			finit
			mov operator,ebx
			mov len,ebx
			mov num,ebx
			mov equal,ebx
			mov ebx,1
			mov divisionIsZero,ebx
			mov buf1[0],48
			invoke SetDlgItemText,hWnd,20,addr buf1
			ret
		.endif
	.else  ;否则按默认处理方法处理消息
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif

	xor eax,eax
	ret
_ProcWinMain endp

_WinMain proc  ;窗口程序
	local @stWndClass:WNDCLASSEX  ;定义了一个结构变量，它的类型是WNDCLASSEX，一个窗口类定义了窗口的一些主要属性，图标，光标，背景色等，这些参数不是单个传递，而是封装在WNDCLASSEX中传递的。
	local @stMsg:MSG	;还定义了stMsg，类型是MSG，用来作消息传递的	

	invoke GetModuleHandle,NULL  ;得到应用程序的句柄，把该句柄的值放在hInstance中，句柄是什么？简单点理解就是某个事物的标识，有文件句柄，窗口句柄，可以通过句柄找到对应的事物
	mov hInstance,eax
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass  ;将stWndClass初始化全0

	invoke LoadCursor,0,IDC_ARROW
	mov @stWndClass.hCursor,eax					;---------------------------------------
	push hInstance							;
	pop @stWndClass.hInstance					;
	mov @stWndClass.cbSize,sizeof WNDCLASSEX			;这部分是初始化stWndClass结构中各字段的值，即窗口的各种属性
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW			;入门的话，这部分直接copy- -。。。没时间钻研
	mov @stWndClass.lpfnWndProc,offset _ProcWinMain			;
	;上面这条语句其实就是指定了该窗口程序的窗口过程是_ProcWinMain	;
	mov @stWndClass.hbrBackground,COLOR_WINDOW+1			;
	mov @stWndClass.lpszClassName,offset szClassName		;---------------------------------------
	invoke RegisterClassEx,addr @stWndClass  ;注册窗口类，注册前先填写参数WNDCLASSEX结构

	invoke CreateWindowEx,WS_EX_CLIENTEDGE,\  ;建立窗口
			offset szClassName,offset szCaptionMain,\  ;szClassName和szCaptionMain是在常量段中定义的字符串常量
			WS_OVERLAPPEDWINDOW,100,100,350,370,\	;szClassName是建立窗口使用的类名字符串指针，这里是'MyClass'，表示用'MyClass'类来建立这个窗口，这个窗口拥有'MyClass'的所有属性
			NULL,NULL,hInstance,NULL		;如果改成'button'那么建立的将是一个按钮，szCaptionMain代表的则是窗口的名称，该名称会显示在标题栏中
	mov hWinMain,eax  ;建立窗口后句柄会放在eax中，现在把句柄放在hWinMain中。
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;显示窗口，注意到这个函数传递的参数是窗口的句柄，正如前面所说的，通过句柄可以找到它所标识的事物
	invoke UpdateWindow,hWinMain  ;刷新窗口客户区

	.while TRUE  ;进入无限的消息获取和处理的循环
		invoke GetMessage,addr @stMsg,NULL,0,0  ;从消息队列中取出第一个消息，放在stMsg结构中
		.break .if eax==0  ;如果是退出消息，eax将会置成0，退出循环
		invoke TranslateMessage,addr @stMsg  ;这是把基于键盘扫描码的按键信息转换成对应的ASCII码，如果消息不是通过键盘输入的，这步将跳过
		invoke DispatchMessage,addr @stMsg  ;这条语句的作用是找到该窗口程序的窗口过程，通过该窗口过程来处理消息
	.endw
	ret
_WinMain endp

main proc
	call _WinMain  ;主程序就调用了窗口程序和结束程序两个函数
	invoke ExitProcess,NULL
	ret
main endp
end main