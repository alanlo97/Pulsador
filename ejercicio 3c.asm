				#INCLUDE <P16F628A.INC>

				__CONFIG	3F10
	
				LIST	p=16F84

NUMERO		EQU		0X20
CONT_TMR0  	EQU		0X21
FLAG_RESTA 	EQU		0X22

			ORG		0X00
			GOTO 	INICIO

			; SE VIENE A ESTA PARTE CUANDO SE TOCA EL BOTON O CUANDO SE DESBORDA EL TIMER 0

			ORG		0X04			
			BCF		INTCON,GIE    	;	habilitacion global de interrupciones
			BTFSS	INTCON,INTF   	;	si te toco el boton se salta el GOTO siguiente	
			GOTO	INT_TMR0      	;	se hace cada vez que se desborda el timer

			BCF		INTCON,INTF  	; 	se baja el FLAG para que no quede señalado que se sigue tocando el boton
			BSF		STATUS,RP0    	; 	se va al banco 1
			MOVLW	0X20	
			XORWF	OPTION_REG,F  	;	se hace un XOR con 100000 y OPTION,
								  	; 	basicamente cambia TOCS y hace que TMR0 dependa de eventos externos en RA4, 
							 	  	;	COMO NO HAY NADA AHI NO HACE NADA Y SE QUEDA PARADO EL TMR0

			BCF		STATUS,RP0	  	; 	vuelta al banco 0
			GOTO	SALIR_INT

INT_TMR0
			INCF	CONT_TMR0,F		;	incrementa CONT_TMR0
			MOVF	CONT_TMR0,W		;	manda el numero de CONT_TMR0 a W	
			XORLW	.20				;	le hace un XOR al numero del contador guardado en W con 10100

			BTFSS	STATUS,Z		;	si no da 0 (Z en 1) se sale, sino AUMENTA O DECRECE un numero en el DISPLAY
									;	da 0 siempre menos cuando el contador esta en 4, 16 o 20

			GOTO 	SALIR_TMR0
			BTFSC	FLAG_RESTA,0 	;	si el bit de FLAG_RESTA esta en 1 se va a sumar, si esta en 0 se va a restar
			GOTO	RESTA

SUMA
			INCF	NUMERO,F		;	incrementa NUMERO en 1
			BTFSS	NUMERO,4		;   si NUMERO ya llego a 16 se cambia el bit del auxiliar a 1
									;	para que ya no se sume mas y se pase a restar a partir de ahora 

			GOTO	MOSTRAR			;	si NUMERO no llego a 16 entonces se lo muestra en el DISPLAY
			COMF	FLAG_RESTA,F
			DECF	NUMERO,F		;	se le resta 1 a NUMERO

RESTA 
			DECFSZ	NUMERO,F
			COMF	FLAG_RESTA,F

MOSTRAR
			CLRF	CONT_TMR0		;	se borra CONT_TMR0
			MOVF	NUMERO,W		;	se manda el numero de NUMERO a W
			CALL	TAB_DISPLAY		;	se va a la tabla para ver que numero mostrar
			MOVWF	PORTB			

SALIR_TMR0
			BCF		INTCON,T0IF		;	se baja el flag de desbordamiento del TIMER 0
			MOVLW	.61				;	se empieza el TIMER 0 en 61
			MOVWF	TMR0

SALIR_INT
			RETFIE

INICIO
			MOVLW	.61				;	se empieza el TIMER 0 en 61
			MOVWF	TMR0
			BSF		STATUS,RP0
			BCF		OPTION_REG,NOT_RBPU
			MOVLW	b'00000001'
			MOVWF	TRISB	
			BCF		OPTION_REG,T0CS	;	TIMER 0 funciona con los pulsos internos (4us = 0.000004 seg)
			BCF		OPTION_REG,PSA	;	PREESCALER activado
			BSF		OPTION_REG,PS0
			BSF		OPTION_REG,PS1
			BSF		OPTION_REG,PS2
			BSF		INTCON,GIE
			BSF		INTCON,T0IE
			BSF		INTCON,INTE
			BCF		STATUS,RP0

			CLRF	NUMERO			;	NUMERO empieza en CERO
			CLRF	CONT_TMR0		;	CONT_TMR0 empieza en CERO
			CLRF	FLAG_RESTA		;	FLAG_RESTA empieza en CERO
			CLRW
			CALL	TAB_DISPLAY
			MOVWF	PORTB

			GOTO	$

TAB_DISPLAY
			ADDWF	PCL,1
			RETLW 	b'01111110';0
			RETLW 	b'00001100';1	
			RETLW 	b'10110110';2
			RETLW 	b'10011110';3
			RETLW 	b'11001100';4
			RETLW 	b'11011010';5
			RETLW 	b'11111010';6
			RETLW 	b'00001110';7
			RETLW 	b'11111110';8
			RETLW 	b'11011110';9
			RETLW 	b'11101110';A
			RETLW 	b'11111000';B
			RETLW 	b'01110010';C
			RETLW 	b'10111100';D
			RETLW 	b'11110010';E
			RETLW 	b'11100010';F	


			END