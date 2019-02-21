TITLE Sorting Arrays (SortingArrays-5.asm)

; Author: Lindsey Kvarfordt
; Course / Project ID: Assignment #5                 Date: February 20, 2019
; Description: This project demonstrates the use of procedures with parameters to sort a randomly populated array of size n, where n is provided by the user.

INCLUDE Irvine32.inc

.data

introHeader		BYTE		"Lindsey Kvarfordt\n--Sorting Arrays--\nThis program will sort and print an integer array of user defined size, along with the median.\n**EC: ",0
bye     		BYTE		"Goodbye! ",0
intPrompt		BYTE		"Please enter an integer between 10 and 200 for the size of your array: ",0
results			BYTE		"-----RESULTS-----",0
unsortedHeader  BYTE        "Unsorted Array: ",0
sortedHeader    BYTE        "Sorted Array: ",0
medianHeader    BYTE        "Median: ",0
errorMssg		BYTE		"Out of range. Try again."
space			BYTE		9,0                         ;use a tab for prettier spacing

size            DWORD       ?

min_size	    EQU	        10	
max_size        EQU         200      
low             EQU         100
high            EQU         999
.code

main PROC
    push        OFFSET introHeader  ;pass introHeader by reference
    call        introduction        

    push        OFFSET size
    call        getUserData
   
    call        goodbye

	exit							; exit to operating system

main ENDP


;--------------------------------
;Preconditions: None
;PostConditions: Program title, author name, and description are printed to screen
;Description: Prints introduction to screen
;Dependencies: WriteString, Crlf, edx
;--------------------------------
introduction PROC   
    push    ebp                     ;create stack frame
    mov     ebp, esp


    mov		edx, [epb + 141]        ;move the OFFSET of introHeader into edx (141 may not be correct; could be 142 easily)
	call	WriteString
	call	CrLf
	
    pop     ebp
	ret     141
introduction ENDP


;--------------------------------
;Preconditions: none
;PostConditions: the number in EAX is [10,200]
;Description: Reads an integer from the user until it is within range
;Dependencies: ReadInt, WriteString, validateData, edx
;--------------------------------
getUserData PROC    
    push    ebp                     ;create stack frame
    mov     ebp, esp
prompt:
    mov     edx, OFFSET intPrompt   
    call    WriteString
    call    ReadInt

    cmp     eax, min_size         ;compare the value of size to min
    jl      reset
    cmp     eax, max_size
    jg      reset
    jmp     bottom
reset:
    mov     edx, OFFSET errorMssg
    call    WriteString
    call    CrLf
    jmp     prompt
bottom:
    mov     ebx, [ebp+8]            ;move address of size into ebx
    mov     [ebx], eax              ;move validated userinput value into size address
    
    pop     ebp
	ret     4                       ;size is the only parameter passed (4 bytes)
getUserData ENDP


;--------------------------------
;Preconditions: None
;PostConditions: Farewell message is printed
;Description: Farewell message is printed
;Dependencies: WriteString, CrLf, edx
;--------------------------------
goodbye PROC                        
	call	CrLf                    
	call	CrLf
	mov		edx, OFFSET bye
	call	WriteString
	call	Crlf
	ret
goodbye ENDP

END main