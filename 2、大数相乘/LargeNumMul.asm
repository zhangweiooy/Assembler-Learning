.386
.model flat, stdcall
option casemap : none

includelib msvcrt.lib
scanf proto c:dword,:vararg
printf proto c:dword,:vararg

.data
strA db 1000 dup(0)
strB db 1000 dup(0)
resStr db 2000 dup(0)
numA dd 1000 dup(0)
numB dd 1000 dup(0)
res dd 2000 dup(0)
lenA dd 0
lenB dd 0
lenC dd 0
radix dd 10			;���ڽ�λ����
negativeFlag db 0	;���ű�־
minus db "-",0
;�������
inputMsg db "Please input a integer: ", 0ah, 0
szFmt db "%s", 0
outputMsg0 db "The answer is: ", 0ah, 0
outputMsg1 db "%s", 0ah, 0
outputMsg2 db "%s%s", 0ah, 0

.code
;��ת�ַ�������ת��Ϊdword������
strReversetoInt proc far C numStr:ptr byte, numInt:ptr dword, len:dword
	mov ecx, len
	mov esi, numStr
L1:
	movzx eax, byte ptr [esi] ;��չΪdword
	sub eax, 30H ;30HΪ�ַ�'0'��ASCII��ֵ
	push eax
	inc esi
	loop L1 ;�ַ���ȫ����ջ

	mov ecx, len
	mov esi, numInt
L2:
	pop eax
	mov dword ptr [esi], eax
	add esi, 4
	loop L2	;���γ�ջ�浽������

	ret
strReversetoInt endp

;��ת���飬��ת��Ϊbyte���ַ���
intReversetoStr proc far C uses eax esi ecx 
	mov ecx, lenC
	xor esi, esi 
L1:
	mov eax, dword ptr res[4 * esi] 
	add eax, 30H
	push eax
	inc esi
	loop L1 ;��ջ

	mov ecx, lenC
	xor esi, esi
L2:
	pop eax
	mov byte ptr resStr[esi], al ;���γ�ջ���ַ�����
	inc esi
	loop L2
	
	ret
intReversetoStr endp

;�˷�����
multiply proc far C uses eax ebx ecx edx esi
	mov ebx, -1
Loop1: 
	inc ebx
	cmp ebx, lenA
	jnb endLoop1 ;ebx >= lenAʱ����ѭ��
	xor ecx, ecx
Loop2:
	xor edx, edx
	mov eax, dword ptr numA[4 * ebx]
	mul numB[4 * ecx] ;������ᳬ��8���ֽڣ�ֻ��EAX��
	mov esi, ecx
	add esi, ebx ;���±�֮�ͼ�Ϊ�õ�ǰ�������λ
	add res[4 * esi], eax ;������λ��˵Ľ���ӵ�res����Ӧλ��
	inc ecx
	cmp ecx, lenB 
	jnb Loop1 ;ecx>=lenBʱ�������ڲ�ѭ��
	jmp Loop2
endLoop1:
	mov ecx, lenA
	add ecx, lenB	
	inc ecx
	mov lenC, ecx ;lenC = lenA + lenB + 1
	xor ebx, ebx
	.while ebx < ecx
		mov eax, res[4 * ebx]
		xor edx, edx
		div radix
		add res[4 * ebx + 4], eax
		mov res[4 * ebx], edx
		inc ebx
	.endw
	mov ecx, lenC
	.while res[4 * ecx] == 0 ;��������ĩβ��0
		dec ecx
	.endw
	inc ecx ;����Ϊ�±��һ
	mov lenC, ecx
	invoke intReversetoStr ;�������������ת��Ϊbyte�ַ���
	ret
multiply endp

main proc
	;����A��B
	invoke printf, offset inputMsg
	invoke scanf, offset szFmt, offset strA 
	invoke printf, offset inputMsg
	invoke scanf, offset szFmt, offset strB

	.if strA == '-'
		xor negativeFlag, 1 
		xor eax, eax
		.while [strA + 1 + eax] != 0
			inc eax
		.endw
		mov lenA, eax
		invoke strReversetoInt, offset (strA + 1), offset numA, lenA
	.else
		xor eax, eax
		.while [strA + eax] != 0
			inc eax
		.endw
		mov lenA, eax
		invoke strReversetoInt, offset strA, offset numA, lenA
	.endif
	.if strB == '-'
		xor negativeFlag, 1
		xor eax, eax
		.while [strB + 1 + eax] != 0
			inc eax
		.endw
		mov lenB, eax
		invoke strReversetoInt, offset (strB + 1), offset numB, lenB
	.else
		xor eax, eax
		.while [strB + eax] != 0
			inc eax
		.endw
		mov lenB, eax
		invoke strReversetoInt, offset strB, offset numB, lenB
	.endif

	invoke multiply ;���ó˷��������м���

	invoke printf, offset outputMsg0
	.if negativeFlag == 1
		invoke printf, offset outputMsg2, offset minus, offset resStr
	.else 
		invoke printf, offset outputMsg1, offset resStr
	.endif
	ret
main endp
end main