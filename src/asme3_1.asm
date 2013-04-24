.386
DATA SEGMENT USE16
    BUF DB 6,0,6 DUP(0)
    RES DB 5 DUP(0), '$'
    CRLF DB 0DH, 0AH, '$'
    TARG DW 5 DUP(0)
    HINT1 DB 'Input 5 numbers:', 0DH, 0AH, '$'
DATA ENDS

STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS

CODE SEGMENT USE16
ASSUME CS:CODE, DS:DATA, SS:STACK
START:  MOV AX, DATA
        MOV DS, AX
        LEA DX, HINT1
        MOV AH, 9
        INT 21H
        
        MOV SI, 0 ; input count
INNUM:  LEA DX, BUF
        MOV AH, 10
        INT 21H
        LEA DX, CRLF
        MOV AH ,9
        INT 21H
        MOV BL, BUF+1
        MOV BH, 0 ; OFFSET
        CALL ATOI
        MOV TARG+[SI], DX
        ADD SI, 2
        CMP SI, 8
        JLE INNUM
        CALL SORT
        MOV SI, 0
PRES:   MOV DX, TARG+[SI]
        CALL ITOD
        LEA DX, RES
        MOV AH, 9
        INT 21H
        MOV DL, 20H
        MOV AH, 2
        INT 21H
        ADD SI, 2
        CMP SI, 8
        JLE PRES
        
        MOV AH, 4CH
        INT 21H
        
ATOI PROC ; String to Int, input string length in bx, output to dx
        PUSH AX
        PUSH CX
        DEC BX
        MOV AX, 0 ; sum
        MOV CX, 1 ; power
LATI:   MOV DL, BUF+2[BX]
        CALL CATOI
        CMP DX, 0
        JS SYMB ; convert '-' symbol
        IMUL DX, CX
        ADD AX, DX
        IMUL CX, 10
        JMP ELATI
SYMB:   IMUL AX, -1
ELATI:  DEC BX
        JNS LATI
        MOV DX, AX
        POP CX
        POP AX
        RET
ATOI ENDP

CATOI PROC ; Char to Int, input char to dl, output to dx
        CMP DL, 30H
        JGE CDEC
        CMP DL, 2DH
        JNE CNS
        MOV DX, -1
        RET
CNS:    MOV DX, 0
        RET        
CDEC:   SUB DL, 30H
        MOV DH, 0
        RET
CATOI ENDP

ITOD PROC ; Int to decimal string, input to dx, output to RES
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV RES, 0
        CMP DX, 0
        JGE BEGITOD
        MOV RES, 2DH
        IMUL DX, -1
BEGITOD:MOV AX, DX
        MOV BX, 4 ; string position
        MOV CX, 10
LOOPB:  MOV DX, 0
        IDIV CX
        ADD DL, 30H
        MOV RES+[BX], DL
        DEC BX
        JNZ LOOPB
        POP DX
        POP CX
        POP BX
        POP AX
        RET
ITOD ENDP

SORT PROC ; sort int, sort TARG
        PUSH AX
        PUSH BX
        PUSH SI
        PUSH DX
        MOV SI, 0 ; position
OLP:    MOV AX, 1 ; 1 -> is sorted, 0 -> not sorted
ILP:    MOV BX, TARG+[SI]
        MOV DX, TARG+[SI+2]
        CMP BX, DX
        JGE BGED
        MOV AX, 0
        MOV TARG+[SI+2], BX
        MOV TARG+[SI], DX
BGED:   ADD SI, 2
        CMP SI, 8
        JL ILP
        CMP AX, 0
        MOV SI, 0
        JE OLP
        
        POP DX
        POP SI
        POP BX
        POP AX
        RET
SORT ENDP
        
CODE ENDS
    END START
