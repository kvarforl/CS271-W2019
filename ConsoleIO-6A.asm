TITLE Console IO (ConsoleIO-6A.asm)

; Author: Lindsey Kvarfordt
; Course / Project ID: Assignment #6A                Date: March 11th 2019
; Description: This project demonstrates the use of procedures with parameters to sort a randomly populated array of size n, where n is provided by the user.

INCLUDE Irvine32.inc

;--------------------------------
;Writes a string to standard out.
;Params: name of string to be printed
;--------------------------------
displayString MACRO string
    push        edx
    mov         edx, string
    call        WriteString
    call        CrLf 
    pop         edx
ENDM

;--------------------------------
;Prompts user for string and stores result in given var.
;Params: prompt to display, variable to store result in
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

arr_size        EQU         15
max_input	    EQU	        2147483647

.data

introHeader		BYTE		"Lindsey Kvarfordt",10,"--Low Level I/O--",10,"This program will calculate the sum and average of user provided values.",10,"Please provide 15 unsigned integers: make sure they are small enough to fit within a 32 bit register.",0
intPrompt		BYTE		"Please enter an unsigned integer: ",0
results			BYTE		"-----RESULTS-----",0
arrayHeader     BYTE        "Your numbers: ",0
medianHeader    BYTE        "Sum: ",0
averageHeader   BYTE        "Average: ",0
errorMssg		BYTE		"ERROR! Try again.",0
temp_input      BYTE        ?
num_result      DWORD       ?
space			BYTE		9,0                         ;use a tab for prettier spacing
errorFlag		DWORD		0							;0 means no error; 1 means error

num_arr         DWORD       arr_size dup(15)

test_input      BYTE        "5678",0
test_input1     BYTE        "56a",0
test_result1    DWORD       ?
test_result     DWORD       ?

.code
main PROC
	displayString       OFFSET introHeader

	call	getData
	exit	; exit to operating system
main ENDP

;--------------------------------
;Preconditions:
;PostConditions: 
;Description: 
;Dependencies: 
;--------------------------------
getData PROC   
    push        ebp                     ;create stack frame
    mov         ebp, esp

    mov         ecx, 10                 ;get 10 ints fromuser
promptUser:
    getString   intPrompt, temp_input   ;PASS EVERYTHING AS PARAMS!
	push		OFFSET errorFlag
	push		LENGTHOF temp_input
	push		OFFSET num_result
    push        OFFSET temp_input
    call        validateString
	
	mov			eax, errorFlag
	call		WriteDec
	call		Crlf

	cmp			errorFlag, 1
	je			err
	;APPEND NUM_RES TO NUM_ARR
	loop		promptUser
err:	
	mov			edx, OFFSET errorMssg
	call		WriteString
	call		crlf
	jmp			promptUser
    
    pop         ebp
	ret         
getData ENDP

;--------------------------------
;Preconditions:
;PostConditions: num_result holds eithe numeric conversion or -1
;Description: If parameter string is a number, convert and save in num_result. else set num_result to -1
;Dependencies: 
;--------------------------------
validateString PROC
    push    ebp
    mov     ebp, esp
	pushad
                                    ;PUSH OFFSET errorFlag | PUSH LENGTH | PUSH OFFSET num_result | PUSH OFFSET temp_input
																			
    mov     ecx, [ebp+16]	        ;set ecx to length of temp_input
	dec		ecx
    mov     edi, [ebp+12]           ;set edi (dest pointer) to addr of num_result
    mov     esi, [ebp+8]            ;set esi (source pointer) to addr of temp_input string

    cld                             ;set direction to FORWARD
charCheck:
    lodsb                           ;load first char into AL
    cmp     AL, 48                  ;compare to '0'
    jl     invalidChar
    cmp     AL, 57                  ;compare to '9'
    jg     invalidChar
    loop    charCheck               ;after this line, entire string is valid chars and esi is at end

	mov		ecx, [ebp+20]			;set error flag to 0 
	mov		esi, 0
	mov		[ecx],esi 

    mov     ecx, [ebp+16]           ;reset ecx to length of string
	dec		ecx
    
	mov		esi, [ebp+8]
	mov		ebx, 0
	mov		[edi], ebx


charConvert:                        ;num_result = (char_ascii - 48) *10^index power  
    mov		ebx, [edi]
	imul	ebx, 10
	mov		[edi],ebx
	lodsb
	sub		AL, '0'
	add		[edi],eax
    loop    charConvert 
    jmp     bottom 

invalidChar:
	mov		eax, [ebp+20]
	mov		esi, 1
	mov		[eax], esi
    jmp     bottom

bottom:
	popad
    pop     ebp
    ret     20
validateString ENDP

END main
