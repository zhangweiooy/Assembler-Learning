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
hInstance dd ?  ;存放应用程序的句柄
hWinMain dd ?   ;存放窗口的句柄
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
		invoke CreateWindowEx,NULL,offset button,offset showButton,WS_CHILD or WS_VISIBLE,200,80,200,30,hWnd,1,hInstance,NULL  ;1表示该按钮的句柄是1
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
			WS_OVERLAPPEDWINDOW,100,100,600,300,\	;szClassName是建立窗口使用的类名字符串指针，这里是'MyClass'，表示用'MyClass'类来建立这个窗口，这个窗口拥有'MyClass'的所有属性
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