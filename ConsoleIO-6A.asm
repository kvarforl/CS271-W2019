TITLE Console IO (ConsoleIO-6A.asm)

; Author: Lindsey Kvarfordt
; Course / Project ID: Assignment #6A                Date: March 11th 2019
; Description: This project demonstrates the use of procedures with parameters to sort a randomly populated array of size n, where n is provided by the user.

INCLUDE Irvine32.inc

.data

introHeader		BYTE		"Lindsey Kvarfordt",10,"--Low Level I/O--",10,"This program will calculate the sum and average of user provided values.",10,"Please provide 15 unsigned integers: make sure they are small enough to fit within a 32 bit register.",0
intPrompt		BYTE		"Please enter an unsigned integer: ",0
results			BYTE		"-----RESULTS-----",0
arrayHeader     BYTE        "Your numbers: ",0
medianHeader    BYTE        "Sum: ",0
averageHeader   BYTE        "Average: ",0
errorMssg		BYTE		"ERROR! Try again."
temp_input      BYTE        ?
space			BYTE		9,0                         ;use a tab for prettier spacing

arr             DWORD       max_size dup(15)
arr_size        EQU         15

max_input	    EQU	        2147483647

;--------------------------------
Writes a string to standard out.
Params: name of string to be printed
;--------------------------------
displayString MACRO string
    push        edx
    mov         edx, OFFSET string
    call        WriteString
    call        CrLf 
    pop         edx
ENDM

;--------------------------------
Prompts user for string and stores result in given var.
Params: prompt to display, variable to store result in
;--------------------------------
getString MACRO prompt, storage_var
    push        ecx
    push        edx
    mov         edx, OFFSET prompt
    call        WriteString

    mov         edx, OFFSET storage_var
    mov         ecx, SIZEOF storage_var
    call        ReadString
    pop         edx
    pop         ecx
ENDM


.code

main PROC
    displayString       introHeader     

main ENDP


;--------------------------------
;Preconditions:
;PostConditions: 
;Description: 
;Dependencies: 
;--------------------------------
getData PROC   
    push    ebp                     ;create stack frame
    mov     ebp, esp


	
    pop     ebp
	ret     4
getData ENDP


END main