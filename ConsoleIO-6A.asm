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

arr_size        EQU         11
max_input	    EQU	        2147483647

.data

introHeader		BYTE		"Lindsey Kvarfordt",10,"--Low Level I/O--",10,"This program will calculate the sum and average of user provided values.",10,"Please provide 15 unsigned integers: make sure they are small enough to fit within a 32 bit register.",10,0
intPrompt		BYTE		"Please enter an unsigned integer: ",0
results			BYTE		"-----RESULTS-----",0
arrayHeader     BYTE        "Your numbers: ",0
sumHeader    BYTE        "Sum: ",0
averageHeader   BYTE        "Average: ",0
errorMssg		BYTE		"ERROR! Try again.",0
temp_input      BYTE        81 dup(?)
num_result      DWORD       ?
space			BYTE		9,0                         ;use a tab for prettier spacing
errorFlag		DWORD		0							;0 means no error; 1 means error

sum				DWORD		?
num_arr         DWORD       arr_size dup(?)

.code
main PROC
	displayString       OFFSET introHeader

	push	OFFSET num_arr
	push	OFFSET errorFlag
	push	OFFSET num_result
	push	OFFSET temp_input
	call	readVal

	push	OFFSET space
	push	OFFSET temp_input
	push	OFFSET num_arr
	push	OFFSET arrayHeader
	call	printArr

	push	OFFSET sumHeader
	push	OFFSET temp_input
	push	OFFSET sum
	push	OFFSET num_arr
	call	displaySum

	exit	; exit to operating system
main ENDP

;--------------------------------
;Preconditions:	push OFFSET sumHeader. OFFSET temp_input, OFFSET sum_storage, OFFSET arr 
;PostConditions: 
;Description: 
;Dependencies:
;--------------------------------
displaySum PROC
	push	ebp
	mov		ebp, esp
	pushad

	displayString [ebp+20]

	mov		ecx, arr_size
	dec		ecx
	mov		esi, [ebp+8]			;set esi to front of arr

	mov		eax, 0					;initialize eax to 0
top:
	add		eax, [esi]
	add		esi, 4
	loop	top

	mov		ebx, [ebp+12]			;store val of eax in sum_storage
	mov		[ebx], eax

	push	[ebp+12]
	push	[ebp+16]
	call	WriteVal
	call	CrLf
	popad
	pop		ebp
	ret		16
displaySum ENDP

;--------------------------------
;Preconditions:	Push OFFSET space, OFFSET storage_var, OFFSET arr., OFFSET arrHeader. arrsize is global constant
;PostConditions: Array is printed to screen
;Description: Prints an array
;Dependencies: displayString, writeVal
;--------------------------------
printArr PROC
	push	ebp
	mov		ebp, esp
	pushad
	mov		esi, [ebp+12]		;set esi to front of numeric array
	displayString [ebp+8]		;display array header
	call	crlf
	mov		ecx, arr_size
	dec		ecx

top:
	push	esi
	push	[ebp+16]
	call	writeVal
	displayString [ebp+20]
	add		esi, 4
	loop	top

	call	crlf

	popad
	pop		ebp
	ret		16
printArr ENDP


;--------------------------------
;Preconditions:	push params in order OFFSET NUM, OFFSET storage_var. Storage var must be at least 11 bytes	
;PostConditions: numeric value has been displayed to screen as a string
;Description: Takes a numeric value, converts it to a string, and displays it to the screen
;Dependencies: displayString
;--------------------------------
writeVal PROC
	push	ebp
	mov		ebp,esp
	pushad

	mov		edi, [ebp+8]			;fill first 21 bytes of storage val with \0 (gives room to construct string backwards)
	mov		al, 0
	mov		ecx, 21
	cld
	rep		stosb

	dec		edi						;keep a null terminator
	std								;set direction to go backwards
	
	mov		ebx, [ebp+12]			;initialize eax to num
	mov		eax, [ebx]
	;mov		eax, num_result
top:
	mov		ebx, 0
	cmp		eax, ebx
	je		start_shift
		
	cdq								;divide eax by 10 until quotient is 0. 
	mov		ebx, 10
	div		ebx

	push	eax						;store remainder at end of string
	add		edx, '0'
	mov		eax, edx
	stosb
	pop		eax
	jmp		top

start_shift:
	cld
	mov		esi, edi				;move string to the front of the storage variable
	inc		esi
	mov		edi, [ebp+8]
shift:
	mov		ebx, 0
	cmp		[esi], ebx				;compare esi to null (will be end of string shift)
	je		bottom
	lodsb
	stosb
	jmp		shift
	jmp		bottom
bottom:
	displayString	[ebp+8]			;display storage value
	popad
	pop				ebp
	ret				8
writeVal ENDP

;--------------------------------
;Preconditions: Params are pushed in order OFFSET num_arr, OFFSET errorFlag, OFFSET num_result, OFFSET temp_input. Array size is a global constant
;PostConditions: The array passed is filled with numeric user input
;Description: Prompts user to provide valid integers until array is full
;Dependencies: validateString
;--------------------------------
readVal PROC   
    push        ebp                     ;create stack frame
    mov         ebp, esp
	pushad
	mov			esi, [ebp+20]			;set ESI to the start of the array

    mov         ecx, arr_size           ;get an arrays worth of ints fromuser
	dec			ecx
promptUser:
    getString   intPrompt, temp_input   ;PASS EVERYTHING AS PARAMS!
	push		[ebp+16]				;OFFSET errorFlag
	push		[ebp+12]				;OFFSET num_result
    push        [ebp+8]					;OFFSET temp_input
    call        validateString

	mov			eax, [ebp+16]
	mov			ebx, 1
	cmp			[eax], ebx
	je			err

	mov			eax, [ebp+12]
	mov			ebx, [eax]
	mov			[esi], ebx				;APPEND NUM_RES TO NUM_ARR
	add			esi, 4
	loop		promptUser
	jmp			bottom
err:	
	mov			edx, OFFSET errorMssg
	call		WriteString
	call		crlf
	jmp			promptUser

bottom:
	popad
    pop         ebp
	ret         16
readVal ENDP

;--------------------------------
;Preconditions: Params have been pushed in order: OFFSET errorFlag | OFFSET num_result | OFFSET temp_input
;PostConditions: num_result holds numeric conversion. Error flag is 0 if all good, 1 if error.
;Description: If parameter string is a number, convert and save in num_result. Otherwise, sets error flag and exits
;Dependencies: none
;--------------------------------
validateString PROC
    push    ebp
    mov     ebp, esp
	pushad
                                    ;PUSH OFFSET errorFlag | PUSH OFFSET num_result | PUSH OFFSET temp_input
																			
    mov     edi, [ebp+12]           ;set edi (dest pointer) to addr of num_result
    mov     esi, [ebp+8]            ;set esi (source pointer) to addr of temp_input string

    cld                             ;set direction to FORWARD
charCheck:
    lodsb                           ;load first char into AL
	cmp		AL, 0
	je		stringGood
    cmp     AL, 48                  ;compare to '0'
    jl		invalidChar
    cmp     AL, 57                  ;compare to '9'
    jg		invalidChar
    jmp		charCheck               ;after this line, entire string is valid chars and esi is at end
stringGood:
	mov		ecx, [ebp+16]			;set error flag to 0 
	mov		esi, 0
	mov		[ecx],esi 

    
	mov		esi, [ebp+8]
	mov		ebx, 0
	mov		[edi], ebx


charConvert:                        ;num_result = (char_ascii - 48) *10^index power  
    
	lodsb
	cmp		AL, 0
	je		bottom
	sub		AL, '0'
	mov		ebx, [edi]
	imul	ebx, 10
	mov		[edi],ebx
	add		[edi],eax
    jmp		charConvert
    jmp     bottom 

invalidChar:
	mov		eax, [ebp+16]
	mov		esi, 1
	mov		[eax], esi
    jmp     bottom

bottom:
	popad
    pop     ebp
    ret     12
validateString ENDP

END main
