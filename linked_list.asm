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

	
	push rax		;push head to stack
	push rax		;this will become our tail

	;ADDING NODES TO LL
	;set up head (first node)
	mov rax, 0x41		;A character in our new node
	mov rdi, 0		;prev_ptr is null because this is head
	mov rsi, qword [rsp+8]		;bottom of our heap where we want our head node to be placed
	call add_node

	mov rax, 0x42		;B in our new node
	mov rdi, qword [rsp]	;bottom of stack contains our tail, move that address to rdi
	add qword [rsp], 9	;advance tail 
	mov rsi, qword [rsp]	;pass our new tail (new node) to add_node
	call add_node
	
	mov rax, 0x43		;C in our new node
	mov rdi, qword [rsp]	;bottom of stack contains our tail, move that address to rdi
	add qword [rsp], 9	;advance tail 
	mov rsi, qword [rsp]	;pass our new tail (new node) to add_node
	call add_node
	
	pop rdi	;remove tail from stack
	mov rax, qword [rsp] 		;get bottom of heap address (which should be the head)
	call traverse_list	
	
	mov rax, 0xb		;munmap
	pop rdi			;pop head from stack to unmap heap area
	mov rsi, 4096
	syscall

	
exit:
	mov rax, 0x3c		;exit
	mov rdi, 0
	syscall

add_node:			;add_node(char new_char, node* prev_node, node* new_node) 
	mov [rsi], al		;add new_char to our node
	mov word [rsi+1], 0	;set our next_ptr to null

	test rdi, rdi
	jz skip_prev		;if prev pointer is 0 (null) then don't get previous pointer (for head)
	mov [rdi+1], rsi	;move address of current node to previous node
skip_prev:
	ret
	

traverse_list: 			;traverse_list(node *head)
	push rax		;preserve struct address on stack
	mov al, byte [rax]	;dereference struct to get char
	call print_char
	pop rax			;restore pointer to struct
	inc rax			;move passed the char to get the address of next node
	mov rbx, [rax]		;dereference next address
	mov rax, [rax]		;store next node in rax to prepare to jump
	test rbx, rbx
	jnz traverse_list	;if next pointer doesn't point to null then jump to next node
	ret
	

print_char:			;print_char(char c)
	sub rsp, 2		;one char + 0x0a
	mov byte [rsp], al
	mov byte [rsp+1], 0xa
	mov rsi, rsp
	mov rdi, 2
	mov rax, 0x1
	mov rdx, 2
	syscall
	add rsp, 2
	ret
