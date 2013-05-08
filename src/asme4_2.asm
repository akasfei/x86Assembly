.MODEL SMALL
.386
INCLUDE COREIO.LIB

STU STRUCT
    SNAME DB 16 DUP('$')
    CHN DB ?
    MTH DB ?
    TOTAL DB ?
STU ENDS

.DATA
    BUF DB 15,0,15 DUP(0)
    RES DB 5 DUP(0), '$'
    TARG DW 0
    STU1 STU <>
    HINT1 DB 'Name : $'
    HINT2 DB 'Chinese score : $'
    HINT3 DB 'Math score : $'
    HINT4 DB 'Total score : $'
;
.STACK 200
;
.CODE
START:
        ATOI PROTO NEAR STDCALL, LEN: BYTE
        CATOI PROTO NEAR STDCALL
        ITOA PROTO NEAR STDCALL, VAL: WORD, BASE: BYTE
        
        MOV AX, @DATA
        MOV DS, AX
        MOV ES, AX
        WRITE HINT1
        READ BUF
        WRITECRLF
        MOV CL, BUF+1
        MOV CH, 0
        LEA SI, BUF
        ADD SI, 2
        LEA DI, STU1.SNAME
        CLD
        REP MOVSB
        WRITE HINT2
        READ BUF
        WRITECRLF
        INVOKE ATOI, BUF+1
        MOV STU1.CHN, DL
        WRITE HINT3
        READ BUF
        WRITECRLF
        INVOKE ATOI, BUF+1
        MOV STU1.MTH, DL
        ADD DL, STU1.CHN
        MOV STU1.TOTAL, DL
        WRITECRLF
        WRITE HINT1
        WRITELN STU1.SNAME
        WRITE HINT2
        MOVSX DX, STU1.CHN
        INVOKE ITOA, DX, 10
        WRITELN RES
        WRITE HINT3
        MOVSX DX, STU1.MTH
        INVOKE ITOA, DX, 10
        WRITELN RES
        WRITE HINT4
        MOVSX DX, STU1.TOTAL
        INVOKE ITOA, DX, 10
        WRITELN RES
        MOV AH, 4CH
        INT 21H
        
ATOI PROC NEAR STDCALL USES AX BX CX, LEN: BYTE ; String to Int
        MOV BL, LEN
        MOV BH, 0
        DEC BX
        MOV AX, 0 ; sum
        MOV CX, 1 ; power
LATI:   MOV DL, BUF+2[BX]
        INVOKE CATOI
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
        RET
ATOI ENDP

CATOI PROC NEAR STDCALL; Char to Int, input char to dl, output to dx
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

ITOA PROC NEAR STDCALL USES AX BX CX DX, VAL: WORD, BASE: BYTE; Int to decimal string, output to RES
        MOV RES, 0
        CMP DX, 0
        JGE BEGITOH
        MOV RES, 2DH
        IMUL DX, -1
BEGITOH:MOV AX, DX
        MOV BX, 4 ; string position
        MOV CL, BASE
        MOV CH, 0
LOOPH:  MOV DX, 0
        IDIV CX
        CMP DX, 10 ; DX <- AX MOD 16
        JGE CHEX
        ADD DL, 30H
        JMP PHEX
CHEX:   SUB DX, 10
        ADD DL, 41H
PHEX:   MOV RES+[BX], DL
        DEC BX
        JNZ LOOPH
        RET
ITOA ENDP
    END START