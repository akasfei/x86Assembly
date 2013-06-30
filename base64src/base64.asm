toBASE64 PROC pSrc:DWORD, pOut:DWORD, len:DWORD, pOutSize:DWORD

    MOV ECX, len
    MOV ESI, pSrc ;bytes from source
    MOV EDI, OFFSET base64tab
    PUSH EBP
    MOV EBP, pOut
    MOV DWORD PTR [pOutSize], 0
src_byteLoop:    
    ADD DWORD PTR [pOutSize], 4

    XOR EAX, EAX

    ;read 3 bytes
    MOV AH, BYTE PTR[ESI]
    MOV AL, BYTE PTR[ESI+1]
    SHL EAX, 16
    MOV AH, BYTE PTR[ESI+2]
    ;manipulate in EDX bitset1
    MOV EDX, EAX
    SHL EAX, 6 ;done first 6 bits
    SHR EDX, 26            
    MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
    MOV BYTE PTR [EBP], BL
    INC EBP ;next buf
    ;manipulate in EDX bitset2
    MOV EDX, EAX
    SHL EAX, 6 ;done first 6 bits

    SHR EDX, 26
    MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
    MOV BYTE PTR[EBP], BL
    INC EBP ;next buf

    ;manipulate in EDX bitset3
    MOV EDX, EAX
    SHL EAX, 6 ;done first 6 bits
    SHR EDX, 26
    MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
    MOV BYTE PTR[EBP], BL
    INC EBP ;next buf

    ;manipulate in EDX bitset4
    MOV EDX, EAX
    SHL EAX, 6 ;done first 6 bits

    SHR EDX, 26
    MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
    MOV BYTE PTR[EBP], BL
    INC EBP ;next buf

    ;done these bytes
    ADD ESI, 3
    SUB ECX, 3

    CMP ECX, 3
    JGE src_byteLoop ;still got src bytes
                
    XOR EAX, EAX ;set to zero (pad count)
    CMP ECX, 0 

    JZ finished
        ;need to pad out some extra bytes
        ADD DWORD PTR [pOutSize], 4

        XOR EAX, EAX
        ;read in 3 bytes regardless of junk data following pSrc - already zero from above)
        MOV AH, BYTE PTR[ESI]
        MOV AL, BYTE PTR[ESI+1]
        SHL EAX, 16
        MOV AH, BYTE PTR[ESI+2]

        SUB ECX, 3 ;bytes just read
        NEG ECX ;+ve inverse
        MOV EDX, ECX ;save how many bytes need padding

        ;as per the RFC, any padded bytes should be 0s
        MOV ESI, 00FFFFFFH
        LEA ECX, DWORD PTR[ECX*8+8] ;calculate bitmask to shift
        SHL ESI, cl
        AND EAX, ESI ;mask out the junk bytes

        MOV ECX, EDX ;restore pad count

        ;manipulate in EDX byte 1
        MOV EDX, EAX
        SHL EAX, 6 ;done first 6 bits                        

        SHR EDX, 26
        MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
        MOV BYTE PTR[EBP], BL
        INC EBP ;next buf

         ;manipulate in EDX byte 2
        MOV EDX, EAX
        SHL EAX, 6 ;done first 6 bits                        

        SHR EDX, 26
        MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
        MOV BYTE PTR[EBP], BL
        INC EBP ;next buf

         ;manipulate in EDX byte 3
        MOV EDX, EAX
        SHL EAX, 6 ;done first 6 bits                        

        SHR EDX, 26
        MOV BL, BYTE PTR [EDI+EDX]             ;put char in buffer
        MOV BYTE PTR[EBP], BL
        INC EBP                                           ;next buf

         ;manipulate in EDX byte 3
        MOV EDX, EAX
        SHL EAX, 6                                     ;done first 6 bits                        

        SHR EDX, 26
        MOV BL, BYTE PTR [EDI+EDX]                   ;put char in buffer
        MOV BYTE PTR[EBP], BL
        INC EBP                                           ;next buf

        MOV EAX, ECX                               ;'return' pad count

finished:
        TEST EAX, EAX
        JZ endF
        ;some bytes were padding, put them as =

        SUB EBP, EAX  ;move ptr back for num bytes to pad
padChars:
        MOV BYTE PTR[EBP], '='
        INC EBP
        DEC EAX

        JNZ padChars
 
endF:
    POP EBP
    RET
                  
toBASE64 ENDP