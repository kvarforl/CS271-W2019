TITLE Sorting Arrays (SortingArrays-5.asm)

; Author: Lindsey Kvarfordt
; Course / Project ID: Assignment #5                 Date: February 20, 2019
; Description: This project demonstrates the use of procedures with parameters to sort a randomly populated array of size n, where n is provided by the user.

INCLUDE Irvine32.inc

.data

authorName		BYTE		"Lindsey Kvarfordt",0
programName		BYTE		"--Sorting Arrays--",0
welcome	    	BYTE		"????",0
ecMssg			BYTE		"**EC: ",0
bye     		BYTE		"Goodbye! ",0
intPrompt		BYTE		"Please enter an integer between 10 and 200: ",0
results			BYTE		"-----RESULTS-----",0
errorMssg		BYTE		"Out of range. Try again."
space			BYTE		9,0

size            DWORD       ?

min_size	    EQU	        10	
max_size        EQU         200      
low             EQU         100
high            EQU         999
.code

main PROC

    call        introduction
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
introduction PROC                    ;Preconditions: none.                   
    mov		edx, OFFSET programName
	call	WriteString
	call	CrLf
	mov		edx, OFFSET authorName
	call	WriteString
	call	CrLf
    mov     edx, OFFSET welcome
    call    WriteString
    call    CrLf
	mov		edx, OFFSET ecMssg
	call	WriteString
	call	CrLf
	ret
introduction ENDP


;--------------------------------
;Preconditions: none
;PostConditions: the number in EAX is [1,400]
;Description: Reads an integer from the user until it is within range
;Dependencies: ReadInt, WriteString, validateData, edx
;--------------------------------
getUserData PROC                    
    mov     edx, OFFSET intPrompt   
    call    WriteString
    call    ReadInt

    call    validateData
	ret
getUserData ENDP


;--------------------------------
;Preconditions: number to validate is in eax; getUserData exists
;PostConditions: number in EAX is [1,400]
;Description: checks that eax is within range
;Dependencies: getUserData, WriteString, CrLf, eax, edx
;--------------------------------
validateData PROC                   
    cmp     eax, min_size                  ;PostConditions: number in EAX is [min_size,max_size]
    jl      reset
    cmp     eax, max_size
    jg      reset
    jmp     bottom
reset:
    mov     edx, OFFSET errorMssg
    call    WriteString
    call    CrLf
    call    getUserData
bottom:
	ret
validateData ENDP


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