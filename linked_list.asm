section .text
global _start

_start:
	;size of our struct: 1 + 8 (char + pointer) = 9 bytes
	
	mov rax, 0x9 		;mmap
	mov rdi, 0		;addr == (void *)0
	mov rsi, 4096		;len (4096 bytes, 1 page)
	mov rdx, 2		;prot_write
	or rdx, 1		;prot_read
	mov r10, 2		;map private
	or r10, 32		;or with map anon
	mov r8, -1		;-1 fd
	mov r9, 0		;offset 0
	syscall

	cmp rax, 0
	jl exit

	
	mov rbx, rax
	push rax		;push bottom of heap address to stack

	mov word [rax], 0	;head of LL
	add rax, 8
	
	mov byte [rax], 0x41	;new LL node
	add rax, 1
	mov word [rax], 0

	

 	sub rax, 1
	mov [rbx], rax	 	;set head

	push rbx
	push rax
	mov rdi, rbx
	call traverse_list
	pop rax
	pop rbx
	
	
	mov rax, 0xb		;munmap
	pop rdi
	mov rsi, 4096
	syscall


	
exit:
	mov rax, 0x3c		;exit
	mov rdi, 0
	syscall

traverse_list: 			;traverse_list(void *head)
	mov rdi, [rdi]		;get first node in head by dereferencing first pointer
	call print_char
	add rdi, 1		;incr struct to get pointer to next node
	mov rsi, [rdi]		;get address and move to rsi
	test rsi, rsi
	jnz traverse_list	;if next address is not 0 then repeat loop
	ret
	

print_char:			;print_char(char* c)
	push rdi
	sub rsp, 2		;one char + 0x0a
	mov al, [rdi]
	mov [rsp], al
	mov byte [rsp+1], 0xa
	mov rsi, rsp
	mov rdi, 2
	mov rax, 0x1
	mov rdx, 2
	syscall
	add rsp, 2
	pop rdi
	ret
