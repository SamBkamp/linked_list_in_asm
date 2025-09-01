# Linked lists in x86 assembly

Why? Because linked lists in C are too easy, also my time is worthless clearly


## How does it work?

This implementation uses 3 functions and lets you interface with 2 of them. There is `add_node`, `traverse_list` and `print_char`.

`traverse_list` takes a pointer to the head of your list and traverses it until it reaches the end. It prints each node it traverses. `print_char` is a helper function to print each character.

`add_node` takes 3 arguments, a char to put in the new node, a pointer to the previous node and a pointer to where the new node will sit in memory.

In my example, I use a call to mmap to reserve 1 page of heap memory to put my linked list in, so all the nodes sit next to each other in memory.

### setting up the head

setting up the head is a bit different to any other node, heres an example:

```asm
	;set up head (first node)
	mov rax, 0x41		;A character in our new node
	mov rdi, 0		;prev_ptr is null because this is head
	mov rsi, qword [rsp+8]		;bottom of our heap where we want our head node to be placed
	call add_node

```

for the head, you must pass 0 as the previous node. For the other nodes you must pass the previous node (the current tail) to the function. Example:

```asm
	mov rax, 0x42		;B in our new node
	mov rdi, qword [rsp]	;bottom of stack contains our tail, move that address to rdi
	add qword [rsp], 9	;advance tail 
	mov rsi, qword [rsp]	;pass our new tail (new node) to add_node
	call add_node

```