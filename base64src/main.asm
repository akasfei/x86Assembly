.386 
.MODEL flat, stdcall 
option casemap :none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib 

;INCLUDE macros.asm

toBASE64 PROTO :DWORD, :DWORD, :DWORD
toBYTE PROTO :DWORD, :DWORD, :DWORD

.DATA
    MsgBoxCaption	DB "Please select working method.",0 
    MsgBoxText	DB "Click OK for Encryption, No for Decryption",0

    srcFileName DB "source.txt", 0
    desFileName DB "dest.txt", 0
    
    DBNOTE1 DB "Encrypting source.txt", 0
    DBNOTE2 DB "Decrypting desc.txt", 0
    
    writeSize DD 0
    
    base64tab DB "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

.DATA? 
    pSFileName DWORD ?
    pDFileName DWORD ?

    hSFile HANDLE ? 
    hSMemory HANDLE ? 
    pSMemory DWORD ? 
    SReadSize DWORD ?  
    SWriteSize DWORD ?
    
    hDFile HANDLE ? 
    hDMemory HANDLE ? 
    pDMemory DWORD ? 
    DReadSize DWORD ?
    DWriteSize DWORD ?
    
    writeStats DWORD ?

.CONST
    SRCMSIZE EQU 201326591 ; 192M
    DESMSIZE EQU 268435455 ; 256M

.CODE 
start:
    ;init memory
    INVOKE GlobalAlloc, GMEM_MOVEABLE OR GMEM_ZEROINIT, DESMSIZE 
    MOV hSMemory, EAX
    INVOKE GlobalLock, hSMemory 
    MOV pSMemory, EAX
    INVOKE GlobalAlloc, GMEM_MOVEABLE OR GMEM_ZEROINIT, DESMSIZE 
    MOV hDMemory, EAX
    INVOKE GlobalLock, hDMemory 
    MOV pDMemory, EAX
    
    ;Mode select
    INVOKE MessageBox, NULL, ADDR MsgBoxText, ADDR MsgBoxCaption, MB_YESNOCANCEL
	
    .IF EAX == IDYES ;Encrytion mode
        INVOKE CreateFile, ADDR srcFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
        MOV hSFile, EAX
        INVOKE CreateFile, ADDR desFileName, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        MOV hDFile, EAX
        INVOKE MessageBox, NULL, ADDR DBNOTE1, ADDR srcFileName, MB_OK
        JMP READF
    .ELSEIF EAX == IDNO ;Decryption mode
        INVOKE CreateFile, ADDR desFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
        MOV hSFile, EAX
        INVOKE CreateFile, ADDR srcFileName, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        MOV hDFile, EAX
        INVOKE MessageBox, NULL, ADDR DBNOTE2, ADDR desFileName, MB_OK
        JMP DECRYPT
    .ELSEIF EAX == IDCANCEL
        JMP MEXIT
    .ENDIF
    
    
    
READF:
    INVOKE ReadFile, hSFile, pSMemory, SRCMSIZE, ADDR SReadSize, NULL
    INVOKE toBASE64, pSMemory, pDMemory, SReadSize

    INVOKE WriteFile, hDFile, pDMemory, writeSize, ADDR writeStats, NULL

    JMP MEXIT
DECRYPT:
    INVOKE ReadFile, hSFile, pSMemory, DESMSIZE, ADDR SReadSize, NULL
    INVOKE toBYTE, pSMemory, pDMemory, SReadSize

    INVOKE WriteFile, hDFile, pDMemory, writeSize, ADDR writeStats, NULL
    JMP MEXIT
    
    
MEXIT:
    ;clean up and exit
    INVOKE GlobalUnlock, pSMemory 
    INVOKE GlobalFree, hSMemory 
    INVOKE CloseHandle, hSFile 
    INVOKE GlobalUnlock, pDMemory 
    INVOKE GlobalFree, hDMemory 
    INVOKE CloseHandle, hDFile 

    INVOKE ExitProcess,NULL
      
    INCLUDE base64.asm
END start