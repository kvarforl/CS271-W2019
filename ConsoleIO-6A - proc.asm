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
    mov         edx, OFFSET string
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
num_result      FWORD       ?
space			BYTE		9,0                         ;use a tab for prettier spacing

num_arr         DWORD       arr_size dup(15)

test_input      BYTE        "5678",0
test_input1     BYTE        "56a",0
test_result1    DWORD       ?
test_result     DWORD       ?

.code
main PROC
	displayString       introHeader

    ;****TEST POWER MACRO****
	push	0
	push	10
	call	power
    call    WriteDec ;EXPECT 1
    call    CrLf
	push	3
	push	10
	call	power
    call    WriteDec ;EXPECT 1000

    ;****TEST VALIDATE STRING****
    push    OFFSET test_input
    push    OFFSET test_result
    call    validateString
    mov     eax, test_result
    call    WriteDec                ;EXPECT 5678
    call    CrLf
    push    OFFSET test_input1
    push    OFFSET test_result1
    call    validateString
    mov     eax, test_result1       ;EXPECT 0
    call    WriteDec
    call    CrLf


	exit	; exit to operating system
main ENDP

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
    push        OFFSET temp_input
    push        OFFSET num_result       ;num_result will contain the numeric form of the string or -1 if NAN
    call        validateString  
    ;if num_result == -1, print errorMssg and jmp without decrementing
    ;else append num_result to num_arr and loop
	
    pop         ebp
	ret         4
getData ENDP

;--------------------------------
;Preconditions:
;PostConditions: num_result holds eithe numeric conversion or -1
;Description: If parameter string is a number, convert and save in num_result. else set num_result to -1
;Dependencies: 
;--------------------------------
validateString PROC
    pushad
    push    ebp
    mov     ebp, esp

    mov     edi, [ebp+12]           ;set edi (dest pointer) to addr of num_result
    mov     esi, [ebp+8]            ;set esi (source pointer) to addr of temp_input string
    mov     ecx, LENGTHOF esi     ;set ecx to length of temp_input

    cld                             ;set direction to FORWARD
charCheck:
    lodsb                           ;load first char into AL
    cmp     AL, 48
    jle     invalidChar
    cmp     AL, 57
    jge     invalidChar
    loop    charCheck               ;after this line, entire string is valid chars and esi is at end

    mov     ecx, LENGTHOF esi		;reset ecx to size of string
    mov     ebx, 0                  ;use ebx as a power index
    std                             ;set direction flag to backwards
charConvert:                        ;num_result = (char_ascii - 48) *10^index power
    ;DO MATH HERE  
    lodsb
    sub     AL, 48
	push	ebx
	push	10
	call	power
    mul     AL                      ;multiply AL (has subtracted ascii val) by EAX(from power macro)

    add     eax, num_result         ;num_result += contents of eax
    mov     num_result, eax

    inc     ebx
    loop    charConvert 
    jmp     bottom 

invalidChar:
    mov     [edi], -1               ;set num_result to -1 and exit
    jmp     bottom

bottom:
    pop     ebp
    popad
    ret     12
validateString ENDP

;PUSH EXPONENT, THEN BASE
power PROC
    push    ecx
	push	ebx
    push    edx     ;might be altered to hold overflow of addition

	push	ebp
    mov     ebp, esp

    mov     ecx, [ebp+8]		;exponent
    mov     eax, [ebp+12]		;base
    cmp     ecx, 0
    je      power_zero
L1:
	mov		ebx, eax
    mul     ebx
    loop    L1
    jmp     bottom1
power_zero:
    mov     eax, 1
bottom1:
	pop		ebp
    pop     edx
	pop		ebx
    pop     ecx
	ret		12
power ENDP

END main
