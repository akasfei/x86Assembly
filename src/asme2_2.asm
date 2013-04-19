.386
DATA SEGMENT USE16
    HINT1 DB 'Input String 1', 0DH, 0AH, '$'
    STR1 DB 49,0,50 DUP(0)
    HINT2 DB 'Input String 2', 0DH, 0AH, '$'
    STR2 DB 49,0,50 DUP(0)
    CRLF DB 0DH, 0AH, '$'
    RESE DB 'MATCH', 0DH, 0AH, '$'
    RESNE DB 'NOT MATCH', 0DH, 0AH, '$'
DATA ENDS

STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS

CODE SEGMENT USE16
        ASSUME CS:CODE, DS:DATA, SS:STACK
START:  MOV AX, DATA
        MOV DS, AX
        LEA DX, HINT1
        MOV AH ,9
        INT 21H
        LEA DX, STR1
        MOV AH, 10
        INT 21H
        LEA DX, CRLF
        MOV AH ,9
        INT 21H
        LEA DX, HINT2
        MOV AH ,9
        INT 21H
        LEA DX, STR2
        MOV AH, 10
        INT 21H
        LEA DX, CRLF
        MOV AH ,9
        INT 21H
        MOV BL, STR1+1
        MOV BH, 0
        MOV SI, BX
        CMP BL, STR2+1
        JNZ RES             ; Jump if lengths differ
LOOPA:  MOV DL, STR1+2[SI]  ; Compare each character
        CMP DL, STR2+2[SI]
        JNE RES             ; if characters differ, break loop so SI != 0
        DEC SI
        JNS LOOPA
RES:    CMP SI, 0
        JGE CNE
        LEA DX, RESE
        JMP PRES
CNE:    LEA DX, RESNE
PRES:   MOV AH, 9
        INT 21H
        MOV AH, 4C
        INT 21H
CODE ENDS
    END START