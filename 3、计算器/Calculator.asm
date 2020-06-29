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
hInstance dd ?  ;���Ӧ�ó���ľ��
hWinMain dd ?   ;��Ŵ��ڵľ��
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
_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam  ;���ڹ���
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hDc

	mov eax,uMsg  ;uMsg����Ϣ���ͣ��������WM_PAINT,WM_CREATE

	.if eax==WM_PAINT  ;������Լ����ƿͻ�����������Щ���룬����һ�δ򿪴��ڻ���ʾʲô��Ϣ
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax

		invoke GetClientRect,hWnd,addr @stRect
		invoke DrawText,@hDc,addr szText,-1,addr @stRect,DT_SINGLELINE or DT_CENTER or DT_VCENTER  ;���ｫ��ʾszText����ַ���
		invoke EndPaint,hWnd,addr @stPs
	
	.elseif eax==WM_CLOSE  ;���ڹر���Ϣ
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL

	.elseif eax==WM_CREATE  ;��������  ��������ʾ����һ����ť������button�ַ���ֵ��'button'�������ݶζ��壬��ʾҪ��������һ����ť��showButton��ʾ�ð�ť�ϵ���ʾ��Ϣ
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
	.else  ;����Ĭ�ϴ�����������Ϣ
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif

	xor eax,eax
	ret
_ProcWinMain endp

_WinMain proc  ;���ڳ���
	local @stWndClass:WNDCLASSEX  ;������һ���ṹ����������������WNDCLASSEX��һ�������ඨ���˴��ڵ�һЩ��Ҫ���ԣ�ͼ�꣬��꣬����ɫ�ȣ���Щ�������ǵ������ݣ����Ƿ�װ��WNDCLASSEX�д��ݵġ�
	local @stMsg:MSG	;��������stMsg��������MSG����������Ϣ���ݵ�	

	invoke GetModuleHandle,NULL  ;�õ�Ӧ�ó���ľ�����Ѹþ����ֵ����hInstance�У������ʲô���򵥵�������ĳ������ı�ʶ�����ļ���������ھ��������ͨ������ҵ���Ӧ������
	mov hInstance,eax
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass  ;��stWndClass��ʼ��ȫ0

	invoke LoadCursor,0,IDC_ARROW
	mov @stWndClass.hCursor,eax					;---------------------------------------
	push hInstance							;
	pop @stWndClass.hInstance					;
	mov @stWndClass.cbSize,sizeof WNDCLASSEX			;�ⲿ���ǳ�ʼ��stWndClass�ṹ�и��ֶε�ֵ�������ڵĸ�������
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW			;���ŵĻ����ⲿ��ֱ��copy- -������ûʱ������
	mov @stWndClass.lpfnWndProc,offset _ProcWinMain			;
	;�������������ʵ����ָ���˸ô��ڳ���Ĵ��ڹ�����_ProcWinMain	;
	mov @stWndClass.hbrBackground,COLOR_WINDOW+1			;
	mov @stWndClass.lpszClassName,offset szClassName		;---------------------------------------
	invoke RegisterClassEx,addr @stWndClass  ;ע�ᴰ���࣬ע��ǰ����д����WNDCLASSEX�ṹ

	invoke CreateWindowEx,WS_EX_CLIENTEDGE,\  ;��������
			offset szClassName,offset szCaptionMain,\  ;szClassName��szCaptionMain���ڳ������ж�����ַ�������
			WS_OVERLAPPEDWINDOW,100,100,350,370,\	;szClassName�ǽ�������ʹ�õ������ַ���ָ�룬������'MyClass'����ʾ��'MyClass'��������������ڣ��������ӵ��'MyClass'����������
			NULL,NULL,hInstance,NULL		;����ĳ�'button'��ô�����Ľ���һ����ť��szCaptionMain��������Ǵ��ڵ����ƣ������ƻ���ʾ�ڱ�������
	mov hWinMain,eax  ;�������ں��������eax�У����ڰѾ������hWinMain�С�
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;��ʾ���ڣ�ע�⵽����������ݵĲ����Ǵ��ڵľ��������ǰ����˵�ģ�ͨ����������ҵ�������ʶ������
	invoke UpdateWindow,hWinMain  ;ˢ�´��ڿͻ���

	.while TRUE  ;�������޵���Ϣ��ȡ�ʹ����ѭ��
		invoke GetMessage,addr @stMsg,NULL,0,0  ;����Ϣ������ȡ����һ����Ϣ������stMsg�ṹ��
		.break .if eax==0  ;������˳���Ϣ��eax�����ó�0���˳�ѭ��
		invoke TranslateMessage,addr @stMsg  ;���ǰѻ��ڼ���ɨ����İ�����Ϣת���ɶ�Ӧ��ASCII�룬�����Ϣ����ͨ����������ģ��ⲽ������
		invoke DispatchMessage,addr @stMsg  ;���������������ҵ��ô��ڳ���Ĵ��ڹ��̣�ͨ���ô��ڹ�����������Ϣ
	.endw
	ret
_WinMain endp

main proc
	call _WinMain  ;������͵����˴��ڳ���ͽ���������������
	invoke ExitProcess,NULL
	ret
main endp
end main