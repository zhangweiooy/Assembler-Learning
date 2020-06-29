.386
.model flat, stdcall
option casemap:none

includelib msvcrt.lib
include winmm.inc   ;timeGetTime函数头文件
includelib winmm.lib

printf PROTO C:dword,:vararg
scanf PROTO C:dword,:vararg
fopen PROTO C: dword,:dword	
fclose PROTO C: dword 
;移动文件位置指针到指定位置
fseek PROTO C: dword,:dword,:dword	
;得到文件位置指针的当前值
ftell PROTO C: dword
fread PROTO C: dword,:dword,:dword,:dword	
fwrite PROTO C: dword,:dword,:dword,:dword
;判断文件末尾
feof PROTO C: dword

.data
    buffer db 2097152 dup (0)
    filepath1 db 100 dup (0)
    filepath2 db 100 dup (0)
    filemode1 db 'rb',0
    filemode2 db 'wb',0
    fp1 dd 0
    fp2 dd 0
    fileLength dd 0
    ;时间
    readStartTime dd 0
    readEndTime dd 0
    timeCost dd 0
    ;文件的存在标志
    flag1 dd 0 
    flag2 dd 0
	;输入、输出信息
    inputMsg1 db "Please input the filepath you want to copy: ", 0ah, 0
	inputMsg2 db "Please input the filepath you want to copy to: ", 0ah, 0      
    error1 db "Can't open source file! ", 0ah, 0
    error2 db "Can't open target file! ", 0ah, 0   
    outputCostMsg db "Execution time: %d ms.", 0ah, 0  
    outputFileLength db "Amount of data: %d bytes.", 0ah, 0
    inputFileMsg db "%s",0
.code

main proc
    ;获取输入源文件与目标文件
    invoke printf, offset inputMsg1
    invoke scanf, offset inputFileMsg, offset filepath1
    invoke printf, offset inputMsg2
    invoke scanf, offset inputFileMsg, offset filepath2
	invoke fopen, offset filepath1, offset filemode1
    mov fp1, eax
    cmp fp1, 0
    jz exit
    mov flag1, 1	;如果文件存在置flag1=1
	
    invoke fopen, offset filepath2, offset filemode2
    mov fp2, eax
    cmp fp2, 0
    jz exit
    mov flag2, 1	;如果文件存在置flag2=1
	
    invoke fseek, fp1, 0, 2	;2为SEEK_END，代表文件末尾
    invoke ftell, fp1	;获取文件的长度
    mov fileLength, eax

    invoke fseek, fp1, 0, 0 ;0为SEEK_SET，代表文件开头
    invoke fseek, fp2, 0, 0 
    invoke timeGetTime	;获取开始时间
   	mov readStartTime, eax
    xor eax, eax
    .while eax == 0
        invoke fread, offset buffer, 1, 2097152, fp1  ;将源文件的内容读入buffer，返回读取到的字节数
        .if eax != 2097152
            invoke fwrite, offset buffer, 1, eax, fp2
        .else
            invoke fwrite, offset buffer, 1, 2097152, fp2  
        .endif
	    invoke feof, fp1 ;判断是否到文件结尾
    .endw
    invoke timeGetTime	;获取结束时间
    mov readEndTime, eax
    
    sub eax, readStartTime
    mov timeCost, eax

    invoke printf, offset outputFileLength, fileLength
    invoke printf, offset outputCostMsg, timeCost  
   	invoke fclose, fp1
    invoke fclose, fp2 
    
exit:
    .if (flag1 == 0)
        invoke printf, offset error1
    .endif
          
    .if (flag2 == 0)
        invoke printf, offset error2 
        invoke fclose, fp1
    .endif

    ret
main endp
end main