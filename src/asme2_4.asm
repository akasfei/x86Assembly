.386
DATA SEGMENT USE16
    BUF DB 6,0,6 DUP(0)
    RES DB 4 DUP(0), '$'
    CRLF DB 0DH, 0AH, '$'
DATA ENDS

STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS

CODE SEGMENT USE16
ASSUME CS:CODE, DS:DATA, SS:STACK
START:  MOV AX, DATA
        MOV DS, AX
        LEA DX, BUF
        MOV AH, 10
        INT 21H
        LEA DX, CRLF
        MOV AH ,9
        INT 21H
        MOV BL, BUF+1
        MOV BH, 0 ; OFFSET
        MOV CX, 1 ; POWER
        MOV AX, 0 ; SUM
        DEC BX
LOOPA:  MOV DL, BUF+2[BX]
        SUB DL, 30H
        MOV DH, 0
        IMUL DX, CX
        ADD AX, DX
        IMUL CX, 10
        DEC BX
        JNS LOOPA
        MOV BX, 3
        MOV CX, 16
LOOPB:  MOV DX, 0
        DIV CX
        CMP DX, 10 ; DX <- AX MOD 16
        JGE CHEX
        ADD DL, 30H
        JMP PHEX
CHEX:   SUB DX, 10
        ADD DL, 41H
PHEX:   MOV RES+[BX], DL
        DEC BX
        JNS LOOPB
        LEA DX, RES
        MOV AH, 9
        INT 21H
        MOV AH, 4C
        INT 21H
CODE ENDS
    END START