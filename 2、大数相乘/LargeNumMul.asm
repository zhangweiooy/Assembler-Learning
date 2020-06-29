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
radix dd 10			;用于进位计算
negativeFlag db 0	;符号标志
minus db "-",0
;输入输出
inputMsg db "Please input a integer: ", 0ah, 0
szFmt db "%s", 0
outputMsg0 db "The answer is: ", 0ah, 0
outputMsg1 db "%s", 0ah, 0
outputMsg2 db "%s%s", 0ah, 0

.code
;反转字符串，并转化为dword型数组
strReversetoInt proc far C numStr:ptr byte, numInt:ptr dword, len:dword
	mov ecx, len
	mov esi, numStr
L1:
	movzx eax, byte ptr [esi] ;扩展为dword
	sub eax, 30H ;30H为字符'0'的ASCII码值
	push eax
	inc esi
	loop L1 ;字符串全部入栈

	mov ecx, len
	mov esi, numInt
L2:
	pop eax
	mov dword ptr [esi], eax
	add esi, 4
	loop L2	;依次出栈存到数组中

	ret
strReversetoInt endp

;反转数组，并转化为byte型字符串
intReversetoStr proc far C uses eax esi ecx 
	mov ecx, lenC
	xor esi, esi 
L1:
	mov eax, dword ptr res[4 * esi] 
	add eax, 30H
	push eax
	inc esi
	loop L1 ;入栈

	mov ecx, lenC
	xor esi, esi
L2:
	pop eax
	mov byte ptr resStr[esi], al ;依次出栈到字符串中
	inc esi
	loop L2
	
	ret
intReversetoStr endp

;乘法计算
multiply proc far C uses eax ebx ecx edx esi
	mov ebx, -1
Loop1: 
	inc ebx
	cmp ebx, lenA
	jnb endLoop1 ;ebx >= lenA时结束循环
	xor ecx, ecx
Loop2:
	xor edx, edx
	mov eax, dword ptr numA[4 * ebx]
	mul numB[4 * ecx] ;结果不会超过8个字节，只在EAX中
	mov esi, ecx
	add esi, ebx ;两下标之和即为该当前结果所在位
	add res[4 * esi], eax ;把两个位相乘的结果加到res的相应位上
	inc ecx
	cmp ecx, lenB 
	jnb Loop1 ;ecx>=lenB时，跳出内层循环
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
	.while res[4 * ecx] == 0 ;不计算结果末尾的0
		dec ecx
	.endw
	inc ecx ;长度为下标加一
	mov lenC, ecx
	invoke intReversetoStr ;将结果数组逆序并转化为byte字符串
	ret
multiply endp

main proc
	;输入A和B
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

	invoke multiply ;调用乘法函数进行计算

	invoke printf, offset outputMsg0
	.if negativeFlag == 1
		invoke printf, offset outputMsg2, offset minus, offset resStr
	.else 
		invoke printf, offset outputMsg1, offset resStr
	.endif
	ret
main endp
end main