.386 
.MODEL flat, stdcall 
option casemap :none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib 

;INCLUDE macros.asm

toBASE64 PROTO :DWORD, :DWORD, :DWORD, :DWORD
;toBYTE PROTO :DWORD, :DWORD, :DWORD

.DATA
    MsgBoxCaption	DB "An example of Cancel,Retry,Continue",0 
    MsgBoxText	DB "Hello Message Box!",0

    srcFileName DB "source.txt", 0
    desFileName DB "dest.txt", 0
    
    DBNOTE1 DB "base64.asm line 11", 0
    DBNOTE2 DB "base64.asm line 64", 0
    DBNOTE3 DB "base64.asm line 66", 0
    DBNOTE4 DB "base64.asm", 0
    DBNOTE5 DB "<= 10", 0
    
    base64tab DB "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

.DATA? 
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
    SRCMSIZE EQU 49151 ; 65536 * 3/4 - 1
    DESMSIZE EQU 65535

.CODE 
start:

	;.IF EAX == IDABORT
		; Abort was pressed

	;.ELSEIF EAX == IDRETRY
		; Retry was pressed

	;.ELSEIF EAX == IDCANCEL
		; Cancel was pressed
	;.ENDIF
    
    INVOKE CreateFile, ADDR srcFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    MOV hSFile, EAX
    INVOKE CreateFile, ADDR desFileName, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    MOV hDFile, EAX
    
    INVOKE GlobalAlloc, GMEM_MOVEABLE OR GMEM_ZEROINIT, SRCMSIZE 
    MOV hSMemory, EAX
    INVOKE GlobalLock, hSMemory 
    MOV pSMemory, EAX
    INVOKE GlobalAlloc, GMEM_MOVEABLE OR GMEM_ZEROINIT, DESMSIZE 
    MOV hDMemory, EAX
    INVOKE GlobalLock, hDMemory 
    MOV pDMemory, EAX
    
    READF:
    INVOKE ReadFile, hSFile, pSMemory, SRCMSIZE, ADDR SReadSize, NULL
    
        ;INVOKE MessageBox, NULL, ADDR MsgBoxText, ADDR MsgBoxCaption, MB_ICONERROR OR MB_ABORTRETRYIGNORE
        
    INVOKE toBASE64, pSMemory, pDMemory, SReadSize, ADDR DWriteSize
    MOV EAX, SReadSize
    MOV EDX, 0
    MOV ECX, 3
    DIV ECX
    .IF EDX > 0
        ADD EAX, 1
    .ENDIF
    MOV ECX, 4
    MUL ECX
    MOV DWriteSize, EAX
    INVOKE MessageBox, NULL, pDMemory, ADDR MsgBoxCaption, MB_OK
    INVOKE WriteFile, hDFile, pDMemory, DWriteSize, ADDR writeStats, NULL
        
    .IF SReadSize <= SRCMSIZE
        INVOKE MessageBox, NULL, pSMemory, ADDR srcFileName, MB_OK
    .ELSE
        JMP READF
    .ENDIF
    
    INVOKE GlobalUnlock, pSMemory 
    INVOKE GlobalFree, hSMemory 
    INVOKE CloseHandle, hSFile 
    INVOKE GlobalUnlock, pDMemory 
    INVOKE GlobalFree, hDMemory 
    INVOKE CloseHandle, hDFile 

	INVOKE ExitProcess,NULL
    
    INCLUDE base64.asm
END start