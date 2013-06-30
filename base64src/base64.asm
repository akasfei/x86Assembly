CONV MACRO ;convert base64 character to base256, input char in DL, output DL
    .IF DL == '+'
        MOV DL, 62
    .ELSEIF DL == '/'
        MOV DL, 63
    .ELSEIF DL >= '0' && DL <= '9'
        ADD DL, 4
    .ELSEIF DL >= 'a' && DL <= 'z'
        SUB DL, 71
    .ELSEIF DL >= 'A' && DL <= 'Z'
        SUB DL, 65
    .ENDIF
ENDM


toBASE64 PROC pSrc:DWORD, pOut:DWORD, len:DWORD

    MOV ECX, len
    MOV ESI, pSrc ;bytes from source
    LEA EDI, base64tab
    PUSH EBP
    MOV EBP, pOut
    LEA EAX, writeSize
    MOV DWORD PTR [EAX], 0
src_byteLoop:    
    LEA EAX, writeSize
    ADD DWORD PTR [EAX], 4

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
        LEA EAX, writeSize
        ADD DWORD PTR [EAX], 4

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
        MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
        MOV BYTE PTR[EBP], BL
        INC EBP ;next buf

         ;manipulate in EDX byte 3
        MOV EDX, EAX
        SHL EAX, 6 ;done first 6 bits                        

        SHR EDX, 26
        MOV BL, BYTE PTR [EDI+EDX] ;put char in buffer
        MOV BYTE PTR[EBP], BL
        INC EBP ;next buf

        MOV EAX, ECX ;'return' pad count

finished:
        TEST EAX, EAX
        JZ endF
        ;some bytes were padding, put them as =

        SUB EBP, EAX ;move ptr back for num bytes to pad
padChars:
        MOV BYTE PTR[EBP], '='
        INC EBP
        DEC EAX

        JNZ padChars
 
endF:
    POP EBP
    RET
                  
toBASE64 ENDP

toBYTE PROC pSrc:DWORD, pOut:DWORD, len:DWORD
    PUSH EBP
    LEA EBX, writeSize
    MOV DWORD PTR [EBX], 0
    MOV ECX, len
    MOV ESI, pSrc ;bytes from source
    PUSH EBP
    MOV EBP, pOut
    
    CMP ECX, 4
    JBE last_24b
    
dec_24bloop:
    LEA EBX, writeSize
    ADD DWORD PTR [EBX], 3
    XOR EAX, EAX ;clear EAX
    MOV EDI, 3
dec_byteloop:
    MOV DL, BYTE PTR [ESI]
    CONV
    ADD AL, DL
    SHL EAX, 6
    INC ESI
    DEC EDI
    JNS dec_byteloop
    
    SHR EAX, 6
    MOV EDI, 2
dec_outbyte:
    MOV BYTE PTR[EBP+EDI], AL
    SHR EAX, 8
    DEC EDI
    JNS dec_outbyte
    
    ADD EBP, 3
    SUB ECX, 4
    CMP ECX, 4
    JA dec_24bloop
    
last_24b:
    XOR EAX, EAX
    MOV EDI, 3
last_byteloop:
    CMP BYTE PTR [ESI], '='
    JE last_out
    MOV DL, BYTE PTR [ESI]
    CONV
    ADD AL, DL
    SHL EAX, 6
    INC ESI
    DEC EDI
    JNS last_byteloop
    
last_out:
    SHR EAX, 6
    .IF EDI == 0 ;one '=' at the end
        SHR EAX, 2
        MOV EDI, 1
        ADD DWORD PTR [EBX], 2
    .ELSEIF EDI == 1 ; two '=' at the end
        SHR EAX, 4
        MOV EDI, 0
        ADD DWORD PTR [EBX], 1
    .ELSE
        MOV EDI, 2
        ADD DWORD PTR [EBX], 3
    .ENDIF
last_outloop:
    MOV BYTE PTR[EBP+EDI], AL
    SHR EAX, 8
    DEC EDI
    JNS last_outloop
    
    POP EBP
    RET
toBYTE ENDP 