.386
.model flat,stdcall
option casemap:none

include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
includelib msvcrt.lib

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
fp1	dword	?
file1	byte	1024 dup(0)

fp2	dword	?
file2	byte	1024 dup(0)

line	dword	0
flag	dword	0
mode	byte	"rb",0
len1 dword ?
len2 dword ?
endF dword 0
endF1 dword 0
endF2 dword 0
noFile byte 'No file matched the path',0ah,0
hInstance dd ?  ;���Ӧ�ó���ľ��
hWinMain dd ?   ;��Ŵ��ڵľ��
showButton byte 'Click to start',0
button db 'button',0
edit db 'edit',0
showEdit1 byte 'File 1 path',0
showEdit2 byte 'File 2 path',0
nofile1 byte 'File1 no exist',0
nofile2 byte 'File2 no exist',0
titleAlert byte 'Alert',0
buf1 byte 1024 dup(0)
buf2 byte 1024 dup(0)
msgOut byte 1024 dup(0)
itoStr byte 1024 dup(0)
msgSam byte 'Two files are the same',0ah,0
msg0 db 'CompResult',0
msg1 byte 'Diff lines No. are:',0ah,0
msg2 byte 'Line No. ',0
msg3 byte ' in both file',0
msg4 byte ' in file ',0
msg5 byte ' ',0ah,0

.const
szClassName db 'MyClass',0
szCaptionMain db 'Text-Comparation',0
szText db 'Please input the full path of the file',0

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
		invoke CreateWindowEx,NULL,offset button,offset showButton,WS_CHILD or WS_VISIBLE,200,80,200,30,hWnd,1,hInstance,NULL  ;1��ʾ�ð�ť�ľ����1
		invoke CreateWindowEx,NULL,offset edit,offset showEdit1,WS_CHILD or WS_VISIBLE,10,10,500,30,hWnd,2,hInstance,NULL
		invoke CreateWindowEx,NULL,offset edit,offset showEdit2,WS_CHILD or WS_VISIBLE,10,50,500,30,hWnd,3,hInstance,NULL
	.elseif eax==WM_COMMAND
		mov eax,wParam
		.if eax==1
			mov eax,0
			mov file1,al
			mov file2,al
			mov fp1,eax
			mov fp2,eax
			mov line,eax
			mov flag,eax
			mov endF,eax
			mov endF1,eax
			mov endF2,eax
			mov msgOut,al
			invoke GetDlgItemText,hWnd,2,offset file1,1024
			invoke GetDlgItemText,hWnd,3,offset file2,1024
			invoke	fopen,offset file1,offset mode
			.if eax==0
				invoke MessageBox,hWnd,offset nofile1,offset titleAlert,MB_OK
				ret
			.endif
			mov fp1,eax
			invoke fopen,offset file2,offset mode
			.if eax==0
				invoke MessageBox,hWnd,offset nofile2,offset titleAlert,MB_OK
				ret
			.endif
			mov fp2,eax
			invoke strcat,offset msgOut,offset msg1
		L1:
			mov eax,0
			mov buf1,al
			mov buf2,al
			mov itoStr,al
			inc line
			invoke fgets,offset buf1,1024,fp1
			push eax
			.if eax==0
				mov eax,1
				mov endF,eax
				mov endF1,eax
			.endif
			invoke fgets,offset buf2,1024,fp2
			push eax
			.if eax==0
				mov eax,1
				mov endF,eax
				mov endF2,eax
			.endif
			invoke strlen,offset buf1
			sub eax,2
			mov len1,eax
			invoke strlen,offset buf2
			sub eax,2
			mov len2,eax
			mov eax,len1
			.if buf1[eax]==13
				mov ebx,0
				mov buf1[eax],bl
			.endif
			mov eax,len2
			.if buf2[eax]==13
				mov ebx,0
				mov buf2[eax],bl
			.endif
			invoke strcmp,offset buf1,offset buf2
			cmp eax,0
			jnz L2
			jmp L3
		L2:
			mov flag,1
			invoke _itoa,line,offset itoStr,10
			invoke strcat,offset msgOut,offset msg2
			invoke strcat,offset msgOut,offset itoStr
			mov eax,endF1
			mov ebx,endF2
			mov ecx,endF
			.if ecx==0
				invoke strcat,offset msgOut,offset msg3
			.else
				.if ebx!=0
					invoke strcat,offset msgOut,offset msg4
					invoke strcat,offset msgOut,offset file1
				.elseif eax!=0
					invoke strcat,offset msgOut,offset msg4
					invoke strcat,offset msgOut,offset file2
				.endif
			.endif
			invoke strcat,offset msgOut,offset msg5
		L3:
			pop eax
			pop ebx
			cmp eax,ebx
			jz L0
			jmp L1
		L0:
			.if flag==1
				invoke MessageBox,hWnd,offset msgOut,offset msg0,MB_OK
			.else
				invoke MessageBox,hWnd,offset msgSam,offset msg0,MB_OK
			.endif
			invoke fclose, fp1
			invoke fclose, fp2
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
			WS_OVERLAPPEDWINDOW,100,100,600,300,\	;szClassName�ǽ�������ʹ�õ������ַ���ָ�룬������'MyClass'����ʾ��'MyClass'��������������ڣ��������ӵ��'MyClass'����������
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