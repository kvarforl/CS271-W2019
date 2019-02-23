TITLE Sorting Arrays (SortingArrays-5.asm)

; Author: Lindsey Kvarfordt
; Course / Project ID: Assignment #5                 Date: February 20, 2019
; Description: This project demonstrates the use of procedures with parameters to sort a randomly populated array of size n, where n is provided by the user.

INCLUDE Irvine32.inc

.data

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

min_size	    EQU	        10	
max_size        EQU         200      
low_bound       EQU         100
high_bound      EQU         999
.code

main PROC
    push        OFFSET introHeader      ;pass introHeader by reference
    call        printMssg        

    push        OFFSET errorMssg
	push		OFFSET intPrompt
    push        OFFSET arr_size
    call        getUserData

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
;Preconditions:
;PostConditions: 
;Description: Procedure is based on example from pg 297 of textbook
;Dependencies: 
;--------------------------------
fillArr PROC    
    push    ebp                     ;create stack frame
    mov     ebp, esp
    pushad                          ;save all registers

    mov     esi, [ebp+12]           ;store address of first arr elem in esi
    mov     ecx, [ebp+8]            ;store array size in loop counter

    cmp     ecx,0
    je      bottom                  ;If counter is zero, skip first loop
first_loop:
    mov     eax, high_bound         ;SETS UPPER BOUND (need to set lower; search for RandomRange documentation)
    call    RandomRange
    mov     [esi], ax               ;put random num into arr at esi
    add     esi, 4                  ;increment iterator (esi)
    loop    first_loop
bottom:
    pop     ebp
    ret     8
fillArr ENDP

END main