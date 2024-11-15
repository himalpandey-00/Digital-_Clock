.model small
.stack 100h

.DATA
X DB ? 		; Stores seconds
Y DB ? 		; Stores minutes
Z DB ? 		; Stores hours
MESSAGE1 DB "Enter a number for hour(0-9): $"; Message prompt for hours input
MESSAGE2 DB "Enter a number for minute (0-9): $"; Message prompt for minutes input
MESSAGE3 DB "Enter a number for second (0-9): $"; Message prompt for seconds input
TENS DB ? 	; Stores tens digit of the split number
UNIT DB ?	; Stores units digit of the split number

.CODE
MAIN PROC
	MOV AX, @DATA 	; Initialize data segment
	MOV DS, AX

Counter:
	MOV CX, 43199 	; Loop counter for 12 hours (43199 iterations)

UserInputs: 			; Procedure to take user input for hour, minute, and seconds

	; Input Hour
	MOV AH, 9 	; Display MESSAGE1
	LEA DX, MESSAGE1 	; Load address of MESSAGE1 into DX
	INT 21H		; Display Message

	MOV AH, 1		; Input character with echo
	INT 21H		
	SUB AL, 30H 		; Convert ASCII input to decimal
	MOV Z, AL 		; Store user input hours
	CALL NewLine	; Go to new line

	; Input Minute
	MOV AH, 9 	; Display MESSAGE2
	LEA DX, MESSAGE2 	; Load address of MESSAGE2 into DX
	INT 21H 	; Display message
	
	MOV AH, 1	; Input character echo
	INT 21H
	SUB AL, 30H		; Convert ASCII input to decimal
	MOV Y, AL 		; Store user input in minutes
	CALL NewLine 	; Go to new line
	
	; Input Seconds 
	MOV AH, 9 	; Display MESSAGE3
	LEA DX, MESSAGE3		; Load address of MESSAGE3 into DX
	INT 21H 		; Display message
	
	MOV AH, 1 	; Input character with echo	
	INT 21H
	SUB AL, 30H 	; Convert ASCII input to decimal
	MOV X, AL 	; Store user input in seconds
	CALL NewLine 	; Go to new line

	JMP Clock 		; Jump to start the clock
	
NewLine: 		; Procedure to print a newline
	MOV DL, 10 		; NewLine character
	MOV AH, 2		; Character display service
	INT 21H 		; Interrupt call to display newline
	RET 			; Return to caller

Splitting: 		; Procedure to split number into tens and units digit
	XOR AH, AH		; Clear Ah
	MOV BL, 10		; Divisor to split number into quotient and remainder 
	DIV BL			; Divide AL by 10, quotient in AL, remainder in AH

	MOV TENS, AL 		; Move quotient to TENS (tens)
	MOV UNIT, AH 		; Move remainder to UNIT (units)
	
	MOV AH, 2 		; Character display service
	
	; Display tens digit
	MOV DL, TENS		; Load tens digit
	ADD DL, 30H			; Convert to ASCII
	INT 21H			; Display tens digit

	; Display units digit
	MOV DL, UNIT 		; Load units digit
	ADD DL, 30H 			; Convert to ASCII
	INT 21H			; Display units digit

				
	RET			; Return to caller

Clock:			; Clock procedure to increment and display time
	
	INC X		; Increment Seconds
	MOV AL, X	; Load seconds into AL
	MOV BL, 60 	; Divisor to split seconds into minutes
	XOR AH, AH 	; Clear AH
	DIV BL 	; Divide AL by 60, quotient in AL, remainder in AH
	MOV X, AH	; Store remainder in seconds

	CMP AL, 1	; Check if a minute has passed
	JNZ SKIP 	; If not, skip incrementing minutes
	INC Y		; Increment minutes if a minute has passed

SKIP: 
	MOV AL, Y	; Load minutes into AL
	XOR AH, AH	; Clear AH
	DIV BL		; Divide AL by 60, quotient in AL, remainder in AH
	MOV Y, AH 	; Store remainder in minutes
	
	CMP AL, 1 	; Check if an hour has passed
	JNZ SKIP1 	; If not, skip incrementing hours
	
	INC Z		; Increment hours if an hour has passed 

SKIP1: 
	MOV AL, Z	; Load hours into AL
	CMP AL, 12 	; Check if hours equal 12
	JNZ DISPLAY 	; If not, jump to display time
	MOV AL, 0	; Reset hours to 0 if 12-hour period completed
	MOV Z, AL	; Stores 0 in hours 

DISPLAY:
	MOV AL, Z	; Load hours into AL
	CALL Splitting 	; Display hours
	
	MOV DL, ':'	; Display “:” as separator 
	MOV AH, 2 	; Character display service
	INT 21H	; Display “:”

	MOV AL, Y	; Load minutes into AL
	CALL Splitting 	; Display minutes
	
	MOV DL, ':'; Display “:” as separator
	MOV AH, 2; Character display service
	INT 21H; Display ‘:’
	
	MOV AL, X; Load seconds into AL
	CALL Splitting; Display seconds

	CALL NewLine; Print newline
	LOOP Clock; Loop until 12 hour complete

EXIT:
	MOV AH, 4CH	; Terminate program
	INT 21H
MAIN ENDP
END MAIN
