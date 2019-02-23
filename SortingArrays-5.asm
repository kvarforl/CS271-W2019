TITLE Sorting Arrays (SortingArrays-5.asm)

; Author: Lindsey Kvarfordt
; Course / Project ID: Assignment #5                 Date: February 20, 2019
; Description: This project demonstrates the use of procedures with parameters to sort a randomly populated array of size n, where n is provided by the user.

INCLUDE Irvine32.inc

.data

min_size	    EQU	        10	
max_size        EQU         200      
low_bound       EQU         100
high_bound      EQU         999

range			EQU			high_bound-low_bound+1

introHeader		BYTE		"Lindsey Kvarfordt",10,"--Sorting Arrays--",10,"This program will sort and print an integer array of user defined size, along with the median.",10,"**EC: ",0
bye     		BYTE		"Goodbye! ",0
intPrompt		BYTE		"Please enter an integer between 10 and 200 for the size of your array: ",0
results			BYTE		"-----RESULTS-----",0
unsortedHeader  BYTE        "Unsorted Array: ",0
sortedHeader    BYTE        "Sorted Array: ",0
medianHeader    BYTE        "Median: ",0
errorMssg		BYTE		"Out of range. Try again."
space			BYTE		9,0                         ;use a tab for prettier spacing

arr             DWORD       max_size dup(?)
arr_size        DWORD       ?


.code

main PROC
	call		Randomize				;Seed random number generator

    push        OFFSET introHeader      ;pass introHeader by reference
    call        printMssg        

    push        OFFSET errorMssg		;get the array size
	push		OFFSET intPrompt
    push        OFFSET arr_size
    call        getUserData

	push		OFFSET arr				;populate array
	push		arr_size
	call		fillArr

	push		OFFSET unsortedHeader	;print  unsorted array
	call		printMssg

	push		OFFSET space			
	push		OFFSET arr
	push		arr_size
	call		printArr

	;SORT ARRAY
	push		OFFSET arr
	push		arr_size
	call		sortArr


	push		OFFSET sortedHeader	;print  sorted array
	call		printMssg

	push		OFFSET space			
	push		OFFSET arr
	push		arr_size
	call		printArr


    push        OFFSET bye
    call        printMssg               ;pass in bye message

	exit							    ; exit to operating system

main ENDP


;--------------------------------
;Preconditions: A string has been pushed to the stack
;PostConditions: The first parameter pushed to the stack is printed
;Description: Prints introduction to screen
;Dependencies: WriteString, Crlf, edx
;--------------------------------
printMssg PROC   
    push    ebp                     ;create stack frame
    mov     ebp, esp


    mov		edx, [ebp + 8]        ;move the offset of intro header into edx
	call	WriteString
	call	CrLf
	
    pop     ebp
	ret     4
printMssg ENDP


;--------------------------------
;Preconditions: parameters are pushed in order; errorMssg, intPrompt, arr_size
;PostConditions: the number in EAX is [10,200]
;Description: Reads an integer from the user until it is within range (defined by constants)
;Dependencies: ReadInt, WriteString, edx
;--------------------------------
getUserData PROC    
    push    ebp                     ;create stack frame
    mov     ebp, esp
prompt:
    mov     edx, [ebp+12]  
    call    WriteString
    call    ReadInt

    cmp     eax, min_size         ;compare the value of size to min
    jl      reset
    cmp     eax, max_size
    jg      reset
    jmp     bottom
reset:
    mov     edx, [ebp+16]
    call    WriteString
    call    CrLf
    jmp     prompt
bottom:
    mov     ebx, [ebp+8]            ;move address of size into ebx
    mov     [ebx], eax              ;move validated userinput value into size address
    
    pop     ebp
	ret     12                       ;3 DWORDs passed (12 bytes)
getUserData ENDP

;--------------------------------
;Preconditions: Arr size must not be 0
;PostConditions: 
;Description: Procedure is based on example from pg 297 of textbook
;Dependencies: 
;--------------------------------
fillArr PROC    
    push    ebp							;create stack frame
    mov     ebp, esp 
    ;pushad								;save all registers

    mov     esi, [ebp+12]				;store address of first arr elem in esi
    mov     ecx, [ebp+8]				;store array size in loop counter

first_loop:
    mov     eax, range					;generates number to upper bound
    call    RandomRange
	add		eax, low_bound				;shifts number into desired range
    mov     [esi], eax					;put random num into arr at esi
    add     esi, 4						;increment iterator (esi)
    loop    first_loop

    pop     ebp
    ret     8
fillArr ENDP


;--------------------------------
;Preconditions: Parameters pushed in order of space, OFFSET arr, arr_size
;PostConditions: Contents of memory from OFFSET arr to OFFSET arr +(arr_size*4) are printed with space as a separating character
;Description: Prints the contents of an array
;Dependencies: EXC, ESI, EBP, WRITEDEC, WRITESTRING
;--------------------------------
printArr PROC
	push	ebp						;create stack frame
	mov		ebp, esp
	mov		ecx, [ebp+8]			;move arr_size into loop counter
	mov		esi, [ebp+12]			;move address of first arr element into esi
top:
	mov		eax, ecx				;check if newline is needed
	cdq
	mov		ebx, 10
	div		ebx
	cmp		edx, 0					;if loop_counter%10 is zero, print a newline
	jne		no_newline
	call	CrLf
no_newline:
	mov		eax, [esi]				;move value of iter pointer (esi) to eax
	call	WriteDec		
	
	mov		edx, [ebp+16]			;print a tab as a space
	call	WriteString
	
	add		esi, 4					;increment iterator
	loop	top
bottom:
	call	CrLf
	pop		ebp
	ret		8
printArr ENDP

;--------------------------------
;Preconditions:params are pushed in order of OFFSET arr, arr_size
;PostConditions: 
;Description: 
;Dependencies: 
;--------------------------------
sortArr PROC
	push	ebp						;create stack frame
	mov		ebp, esp
	mov		ecx, [ebp+8]			;move arr_size into outer loop counter
	dec		ecx						;decrement ecx to keep from seg faulting (set outer loop counter to size-1)
	mov		esi, [ebp+12]			;move address of first arr element into esi

	mov		edi, esi
	sub		edi, 4					;set edi to 4 bytes before first elem; will be incremented to first elem in loop
top_outer:
	add		edi,4
	mov		esi, edi				;set esi to point to the same addr as esi
	push	ecx

	mov		ecx, [ebp+8]			;set inner loop counter to be size-1
	dec		ecx
top_inner:
	add		esi, 4

	mov		ebx, [edi]			;compare base element to other element
	mov		edx, [esi]
	cmp		ebx,edx				
	jg		dont_swap			;don't swap if val edi (ebx) is already > val esi (edx)

	push	[edi]				;use the stack to swap elements
	push	[esi]
	pop		[edi]
	pop		[esi]

dont_swap:
	loop	top_inner
	pop		ecx
	loop	top_outer

	pop		ebp
	ret		8
sortArr ENDP

END main