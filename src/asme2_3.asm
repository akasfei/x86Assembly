.386
DATA SEGMENT USE16
    STR1 DB 'Zero $', 'One  $', 'Two  $', 'Three$', 'Four $', 'Five $', 'Six  $', 'Seven$', 'Eight$', 'Nine $'
    CRLF DB 0DH, 0AH, '$'
DATA ENDS

STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS

CODE SEGMENT USE16
        ASSUME CS:CODE, DS:DATA, SS:STACK
START:  MOV AX, DATA
        MOV DS, AX
        MOV AH, 1
        INT 21H
        LEA DX, CRLF
        MOV AH ,9
        INT 21H
        MOV BL, AL
        MOV BH, 0
        SUB BX, 30H
        IMUL BX, 6
        LEA DX, STR1+[BX]
        MOV AH, 9
        INT 21H
        MOV AH, 4C
        INT 21H
CODE ENDS
    END START