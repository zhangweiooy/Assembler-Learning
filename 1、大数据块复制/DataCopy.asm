.386
.model flat, stdcall
option casemap:none

includelib msvcrt.lib
include winmm.inc   ;timeGetTime����ͷ�ļ�
includelib winmm.lib

printf PROTO C:dword,:vararg
scanf PROTO C:dword,:vararg
fopen PROTO C: dword,:dword	
fclose PROTO C: dword 
;�ƶ��ļ�λ��ָ�뵽ָ��λ��
fseek PROTO C: dword,:dword,:dword	
;�õ��ļ�λ��ָ��ĵ�ǰֵ
ftell PROTO C: dword
fread PROTO C: dword,:dword,:dword,:dword	
fwrite PROTO C: dword,:dword,:dword,:dword
;�ж��ļ�ĩβ
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
    ;ʱ��
    readStartTime dd 0
    readEndTime dd 0
    timeCost dd 0
    ;�ļ��Ĵ��ڱ�־
    flag1 dd 0 
    flag2 dd 0
	;���롢�����Ϣ
    inputMsg1 db "Please input the filepath you want to copy: ", 0ah, 0
	inputMsg2 db "Please input the filepath you want to copy to: ", 0ah, 0      
    error1 db "Can't open source file! ", 0ah, 0
    error2 db "Can't open target file! ", 0ah, 0   
    outputCostMsg db "Execution time: %d ms.", 0ah, 0  
    outputFileLength db "Amount of data: %d bytes.", 0ah, 0
    inputFileMsg db "%s",0
.code

main proc
    ;��ȡ����Դ�ļ���Ŀ���ļ�
    invoke printf, offset inputMsg1
    invoke scanf, offset inputFileMsg, offset filepath1
    invoke printf, offset inputMsg2
    invoke scanf, offset inputFileMsg, offset filepath2
	invoke fopen, offset filepath1, offset filemode1
    mov fp1, eax
    cmp fp1, 0
    jz exit
    mov flag1, 1	;����ļ�������flag1=1
	
    invoke fopen, offset filepath2, offset filemode2
    mov fp2, eax
    cmp fp2, 0
    jz exit
    mov flag2, 1	;����ļ�������flag2=1
	
    invoke fseek, fp1, 0, 2	;2ΪSEEK_END�������ļ�ĩβ
    invoke ftell, fp1	;��ȡ�ļ��ĳ���
    mov fileLength, eax

    invoke fseek, fp1, 0, 0 ;0ΪSEEK_SET�������ļ���ͷ
    invoke fseek, fp2, 0, 0 
    invoke timeGetTime	;��ȡ��ʼʱ��
   	mov readStartTime, eax
    xor eax, eax
    .while eax == 0
        invoke fread, offset buffer, 1, 2097152, fp1  ;��Դ�ļ������ݶ���buffer�����ض�ȡ�����ֽ���
        .if eax != 2097152
            invoke fwrite, offset buffer, 1, eax, fp2
        .else
            invoke fwrite, offset buffer, 1, 2097152, fp2  
        .endif
	    invoke feof, fp1 ;�ж��Ƿ��ļ���β
    .endw
    invoke timeGetTime	;��ȡ����ʱ��
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