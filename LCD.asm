__CONFIG _CONFIG1,0x2FD5
__CONFIG _CONFIG2,0x0700


List P=16F887
    Include <P16F887.INC>
    INCLUDE <Tiempos.inc>

CBLOCK 0x22
TMR0_Tiempo
V_INDEX
V_INDEX2
WR1
WR2
control_4_bits
Escribir_4_bits
ENDC

#DEFINE  RS       PORTE,0
#DEFINE  Enable   PORTB,0

ORG 0                   
GOTO setup          

ORG 4                   
goto TMR0_interrupcion 


setup

bcf   STATUS,RP1
bsf   STATUS,RP0    ; acceso al Banco 1
clrf  TRISB
clrf  TRISD
clrf  TRISE   ; TRISB como Salidas
movlw b'00000000'   ; 0,0,TOCS=1,0, PSA=0, PS2=1,PS1=1,PS0=1
movwf OPTION_REG
bcf   STATUS,RP1
bcf   STATUS,RP0   
movlw b'10100000'   ; GIE=1, 0, T0IE=1, 0 ,0,0,0,0
movwf INTCON        ; Activa la Interrupcion General y la Interrupcion por Timer
movlw d'255'       ; CargaTMR0=255 ,,, Temporizador= Tciclo_Maquina*Preescaler*(256-CargaTMR0)
movwf TMR0          ; Temporizador= 1*256*(256-255)= 256us
clrf PORTB
clrf PORTD
clrf PORTE

Principal

GOTO Principal      ; la interrupcion cada 256us sale del bucle Principal 




TMR0_interrupcion   ; Programa de Interrupcion por Timer

bcf INTCON,T0IF     ;hay que resetar el bit de interrupcion de Timer para que el timer se detenga

LCD_INICIAR

LCD_IN


bcf   RS ; modo Configuracion rs=0;
bsf  Enable
Time_15_ms
call Delay
bcf  Enable

movlw b'00110000'
movwf PORTD
Time_4_ms
call control



movlw b'00110000'
movwf PORTD
Time_100_us
call control


movlw b'00110000'
movwf PORTD
Time_4_ms
call control

movlw b'00100000'
movwf PORTD
Time_4_ms
call control


  movlw b'00101000' ;Modo de Funcionamiento DL=0, N=1 F=0 
  call  Configuracion; Bus de datos 4 Bits, Visualizador 2 Lineas,Caracter 5x7 
  movlw b'00000110' ; Modo de Entrada I/D=1,S=0
  call  Configuracion ;incrementa 1 ,Desplazamiento desactivado
  movlw b'00001100'  ;Activar o Desactivar el Visualizador D=1, U=0, B=0,
  call  Configuracion ;Visualizador Encendido/Cursor Desactivado/ parpadeo del Cursor Activado
  movlw b'00010100' ;Desplazar el Cursor o Visualizador D/C=0 R/L=1 
  call  Configuracion ;Desplazamiento del cursor/Dezplazamiento a la derecha
  movlw b'00000001'  ;borra el visualizador
  call  Configuracion;
  movlw b'00000010' ; poner el cursor al inicio
  call  Configuracion
  movlw b'10000000' ; coordenada 1,1 hasta arriba 
  call  Configuracion
   
 

inicio

movlw d'15'
movwf WR1

movlw d'15'
movwf WR2

clrf V_INDEX
clrf V_INDEX2


I
call Write1
decfsz WR1
GOTO I

call Next

I2
call Write2
decfsz WR2
goto I2


movlw b'10000000'  ;coordenada 1,1 hasta arriba 
call  Configuracion

movlw d'255'          ; CargaTMR0=255 ,,, Temporizador= Tciclo_Maquina*Preescaler*(256-CargaTMR0)
movwf TMR0            ; Temporizador= 1*256*(256-255)= 256us
bcf INTCON,T0IF       ; poner en cero el registro del timer para finalizar interrupcion
retfie 




Write1
call Texto1
call Escribir
Time_20_ms
call Delay
return


Texto1
incf V_INDEX
clrw
movf V_INDEX,W
addwf PCL,F
DT "0Micro PIC16F887" ;Cadena de caracteres envia el codigo ASCII de cada letra por el PORTD
clrf V_INDEX
return

Write2
call Simbolos
call Escribir
Time_20_ms
call Delay
return

Simbolos
incf V_INDEX2
clrw
movf V_INDEX2,W
addwf PCL,F
retlw b'00000000' 
retlw b'11110111'
retlw b'11110011'; Codigo ASCII guardado en laGCROM de algun caracter especial
retlw b'11100000'
retlw b'11110100'; Codigo ASCII guardado en laGCROM de algun caracter especial
retlw b'11111100'
retlw b'10101100'
retlw b'10111100'; Codigo ASCII guardado en laGCROM de algun caracter especial
retlw b'11001100'
clrf V_INDEX2
retlw b'11011100'





Configuracion
bcf   RS  ;RS=0 Modo Configuracion de comandos

movwf control_4_bits  ; ejemplo guarda dato 11110110
andlw b'11110000'; solo toma en cuenta 4 bits altos  1111
movwf PORTD  ; EScribe la mitad del byte 1111 solo escribe Nibble alto D7,D6,D5,D4 
Time_2_ms
call control

swapf control_4_bits,F ; intercambia el nibble bajo de bits por el nibble alto  11110110---01101111
movfw control_4_bits  ;0110 1111
andlw b'11110000'
movwf PORTD  ;EScribe la otra mitad del byte 0110 
Time_2_ms
call control

return


Escribir
    bsf    RS ;RS=1 Modo Escritura de Caracteres

    movwf Escribir_4_bits ; ejemplo guarda dato 11110110
    andlw b'11110000' ; solo toma en cuenta 4 bits 1111
    movwf PORTD ; EScribe la mitad del byte 1111 solo escribe Nibble alto D7,D6,D5,D4 
    Time_20_ms
    call control

    swapf Escribir_4_bits,F ; intercambia el nibble bajo de bits por el nibble alto  11110110----01101111
    movfw Escribir_4_bits ; 0110 1111
    andlw b'11110000'; solo toma en cuenta 4 bits
    movwf PORTD ; EScribe la otra mitad del byte 0110 
    Time_20_ms
    call control

    return

Next
     movlw b'11000000' ; Pon el cursor en la cordenada 1,2 abajo
     call Configuracion 
return
        

 control
bsf  Enable
call Delay   ;Transicion de  1 a 0, indica al LCD que se estan transmitiendo comandos o Escribiendo Caracteres
bcf  Enable     
return

Delay
bcf   INTCON,T0IF   ;hay que resetar el bit de interrupcion de Timer para volver a usar el Timer   ; (Temporizador = 1*256*(256-60)= 50ms))*20 =  50ms*20= 1000ms=1S
movwf TMR0_Tiempo   ; carga la constante  a variable de Tiempo 

TMR0_Carga
 Time_100_us_base         ; CargaTMR0=60 ,,, Temporizador= Tciclo_Maquina*Preescaler*(256-CargaTMR0)
movwf TMR0          ; Temporizador = 1*256*(256-60)= 50ms

time
btfss INTCON,T0IF    ; Cuando T0IF=1 es por que el Timer ya se desbordo pregunta si el Timer se ha desbordado
goto time            ; si no se ha desbordado aun esta corriendo el Tiempo a 50ms
bcf INTCON,T0IF      ; si ya se ha desbordado se cumplio el Tiempo y hay que reiniciar Temporizador
decfsz TMR0_Tiempo   ; decrementa la Variable de Tiempo Multiplicadora  20-1 y salta cuando sea Cero
goto TMR0_Carga      ; cuenta 20 veces hasta 50ms  50ms*20= 1000ms=1S
return     
END