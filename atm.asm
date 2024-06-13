include 'emu8086.inc'
JMP START

DATA SEGMENT 
    TOTAL        DW 20
    IDS1         DW 0000H,0001H,0002H,0003H,0004H,0005H,0006H,0007H,0008H,0009H
    IDS2         DW 000AH,000BH,000CH,000DH,000EH,000FH,0010H,0011H,0012H,0013H 
    PASSWORDS1   DB   00H,  01H,  02H,  03H,  04H,  05H,  06H,  07H,  08H,  09H
    PASSWORDS2   DB   0AH,  0BH,  0CH,  0DH,  0EH,  0FH,  01H,  02H,  03H,  04H
    DATA1        DB 'W*',0
    DATA2        DB 0DH,0AH,'ID: ',0
    DATA3        DB 0DH,0AH,'PW: ',0 
    DATA4        DB 0DH,0AH,'DENIED 0  ',0  
    DATA5        DB 0DH,0AH,'ALLOWED 1 ',0 
    DATA6        DB '**',0 
    DATA7        DB '*',0
    DATA8        DB 0DH,0AH,'Enter withdrawal amount: ',0 
    DATA9        DB 0DH,0AH,'You entered: ',0             
    DATA10       DB '.00',0                 
    DATA11       DB 0DH,0AH,'Transaction complete.',0    
    WITHDRAWAL   DW 1 DUP (?)               ; Storage for withdrawal amount
    IDINPUT      DW 1 DUP (?)
    PASSINPUT    DB 1 DUP (?)  
    CXINPUT      DB 1 DUP (?)
DATA ENDS

CODE SEGMENT

START:MOV  AX,DATA
      MOV  DS,AX  

DEFINE_SCAN_NUM           
DEFINE_PRINT_STRING 
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS 

AGAIN:LEA  SI,DATA1
      CALL PRINT_STRING
      LEA  SI,DATA2
      CALL PRINT_STRING
      MOV  SI,-1

      CALL SCAN_NUM
      MOV  IDINPUT,CX
      MOV  AX,CX
      MOV  CX,0 
L1:   INC  CX
      CMP  CX,TOTAL
      JE   ERROR
      INC  SI
      MOV  DX,SI
      CMP  IDS1[SI],AX
      JE   PASS1
      CMP  IDS2[SI],AX
      JE   PASS2
      JMP  L1
      
SCAN_NUM_MASKED PROC
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
    PUSH    DI

    XOR     CX, CX           ; Clear CX to store the result
    XOR     BX, BX           ; Clear BX to store the digit count

next_digit:
    MOV     AH, 00h          ; BIOS keyboard service
    INT     16h              ; Get character in AL

    CMP     AL, 13           ; Check if Enter key (carriage return)
    JE      input_done

    CMP     AL, 8            ; Check if Backspace key
    JE      backspace

    CMP     AL, '0'          ; Check if it's a valid digit
    JB      next_digit       ; If less than '0', ignore and get the next character
    CMP     AL, '9'
    JA      next_digit       ; If greater than '9', ignore and get the next character

    SUB     AL, '0'          ; Convert ASCII to number (AL now holds the digit 0-9)
    MOV     AH, 0
    PUSH    AX               ; Save the digit on the stack

    ; Update CX with the new digit
    MOV     AX, CX
    MOV     DI, 10
    MUL     DI               ; AX = CX * 10
    POP     DI
    ADD     AX, DI           ; AX = AX + new digit
    MOV     CX, AX

    ; Print asterisk to mask the digit
    MOV     AH, 0Eh
    MOV     AL, '*'
    INT     10h

    INC     BX               ; Increment the digit count
    JMP     next_digit

backspace:
    CMP     BX, 0            ; If no digits, ignore backspace
    JE      next_digit

    DEC     BX               ; Decrement digit count
    MOV     AH, 0Eh
    MOV     AL, 8            ; Backspace
    INT     10h
    MOV     AL, ' '
    INT     10h
    MOV     AL, 8            ; Backspace again
    INT     10h

    ; Remove the last digit from CX
    MOV     AX, CX
    XOR     DX, DX
    MOV     DI, 10
    DIV     DI               ; AX = CX / 10, DX = CX % 10
    MOV     CX, AX
    JMP     next_digit

input_done:
    MOV     CXINPUT, CL      ; Store the result in CXINPUT

    POP     DI
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET
SCAN_NUM_MASKED ENDP

PASS1:LEA  SI,DATA3
      CALL PRINT_STRING        
      CALL SCAN_NUM_MASKED
      MOV  BL, CXINPUT
      MOV  PASSINPUT, BL
      MOV  AX,DX 
      MOV  DX,0002H
      DIV  DL 
      MOV  SI,AX 
      MOV  AL,PASSINPUT
      MOV  AH,00H
      CMP  PASSWORDS1[SI],AL
      JNE  ERROR
      JMP  WDRAW

PASS2:LEA  SI,DATA3
      CALL PRINT_STRING        
      CALL SCAN_NUM_MASKED
      MOV  BL, CXINPUT
      MOV  PASSINPUT, BL
      MOV  AX,DX 
      MOV  DX,0002H
      DIV  DL 
      MOV  SI,AX 
      MOV  AL,PASSINPUT
      MOV  AH,00H
      CMP  PASSWORDS2[SI],AL
      JNE  ERROR
      JMP  WDRAW

WDRAW:; Code for withdrawal amount
      ; WHO YOU KAYO SI SARAH MAY GAWA NETONG PART NA TO
      LEA  SI, DATA8
      CALL PRINT_STRING             
      CALL SCAN_NUM                 
      MOV  WITHDRAWAL, CX           
      LEA  SI, DATA9
      CALL PRINT_STRING             
      MOV  AX, WITHDRAWAL
      CALL PRINT_NUM_UNS            
      LEA  SI, DATA10
      CALL PRINT_STRING             
      LEA  SI, DATA11
      CALL PRINT_STRING
      JMP DONE
      


ERROR:LEA  SI,DATA4
      CALL PRINT_STRING 
      PRINT 0AH      
      PRINT 0DH
      MOV  SI,0
      JMP  AGAIN

DONE: LEA  SI, DATA5
      CALL PRINT_STRING             
      PRINT 0AH
      PRINT 0DH
      LEA  SI, DATA6
      CALL PRINT_STRING             

                   

      MOV  SI, 0      
      
CODE ENDS

END START