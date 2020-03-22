__CONFIG _CONFIG1,0x2FD5
__CONFIG _CONFIG2,0x0700


List P=16F887
    Include <P16F887.INC>

CBLOCK 0x22
Analog
delay1
delay2
ENDC

ORG 0


    setup


bsf STATUS,RP0
bsf STATUS,RP1   ; 11 banco 3
movlw b'11111111';1 el pin es entrada Analogica  0 El pin es Entrada Digital
movwf ANSEL ;permite configurar los pines como entradas Analogicas
bsf STATUS,RP0
bcf STATUS,RP1;10 banco2
bsf TRISA,0; RA0 Entrada    
clrf TRISB;PuertoB Salidas
clrf TRISD;PuertoD Salidas
clrf ADCON1;0 Justificada a la IZquierda se usa ADRESH 
bcf STATUS,RP0
bcf STATUS,RP1;banco 0
movlw b'10000001'; 10= FOSC/32, 0000= Chanel0 AN0,  0= Go done,  1= AD on Activado el ADC
movwf ADCON0 ; registro de configuracion del ADC
clrf PORTB
clrf PORTD

loop

call delay; delay de 20useg necesario para el tiempo de conversion

bsf ADCON0,GO_DONE; Al poner el GO done a 1 inicia la conversion analogica a digital 
muestreo_tiempo_de_conversion
BTFSC ADCON0,GO_DONE ;pregunta si la COnversion ya finalizo , el pic pone el GO  done 0 CUANDO FINALIZA

goto muestreo_tiempo_de_conversion

bsf STATUS,RP0
bcf STATUS,RP1
movf ADRESL,w ; cargo al acumulador los ultimos dos bits MSF de la }Conversion
movwf Analog
movf  Analog,w  
bcf STATUS,RP0
bcf STATUS,RP1
movwf PORTD ; escribe los dos bits MSF al puerto D
movf ADRESH,w; cargo al acumulador el registro que contiene la mayor parte de la conversion ADC
movwf Analog
movf  Analog,w
movwf PORTB ; escribe la conversion ADC en el Puerto B



GOTO loop


delay
movlw .3 
movwf delay1
movlw .2 
movwf delay2

delay_loop
decfsz delay1,f
goto delay_loop
decfsz delay2,f
goto delay_loop
return

END