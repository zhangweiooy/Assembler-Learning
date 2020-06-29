.386
.model flat, stdcall
option casemap:none

includelib msvcrt.lib
printf PROTO C :dword,:vararg

.data
	count dd ?
	i dd ?
	j dd ?
	k dd ?
	l dd ?
	szFmt db '%d ',0ah,0;格式化输出
	
.code
start:
	mov count,0
	mov i,0
l1:
	cmp i,10
	jge final
	mov j,0
l2:
	cmp j,10
	jge continue1
	mov k,0
l3:
	cmp k,10
	jge continue2
	mov l,0
l4:
	cmp l,10
	jge continue3

	mov eax,count
	inc eax
	mov count,eax

	mov eax,l
	inc eax
	mov l,eax
	jmp l4
continue3:
	mov eax,k
	inc eax
	mov k,eax
	jmp l3
continue2:
	mov eax,j
	inc eax
	mov j,eax
	jmp l2
continue1:
	mov eax,i
	inc eax
	mov i,eax
	jmp l1

final:
	mov eax,count
	invoke printf,offset szFmt, eax
	ret
end start
