;	Programme du tutorial TP DESS
;	
	; Include du fichier de description des définitions du 16f877
	include "p16f877.inc"

	list p=16f877
     ;sous programme de l'USART
     
     ;	Programme du tutorial TP DESS
;	

      Converti EQU 0x70
      Q EQU 0x71
      D EQU 0x72
      R EQU 0x73
      Q_dix EQU 0x74
      stock EQU 0x75
      stock_AdresH EQU 0x76
 	
COUNT1		EQU	0x71
COUNT2		EQU	0x72
COUNT3		EQU	0x73
w_temp		EQU	0x74
status_temp	EQU	0x75
Ascii_R		EQU	0x76  
	
compteur	EQU	0x77
	  

	; Start at the reset vector
	org	0x000
	nop
	
	;initiation des interruptions
	
	org	0x004	
	banksel	STATUS
	movwf	w_temp
	movf	STATUS,w
	movwf	status_temp
	btfss	PIR1,RCIF   
	goto	loop_15
	movf	RCREG,w
	movwf	Ascii_R
	
loop_15	    decfsz compteur,f
	    goto    f_inte
	
Timer0	    call    init_compteur
	    
	    comf PORTB
	    
	    	banksel PIR1
	 txif2	btfss	PIR1,TXIF
		goto	txif2
		banksel	TXREG	
		movlw	','
		movwf TXREG
		    nop
	 ;txif3	btfss	PIR1,TXIF
		;goto	txif3
		;banksel	TXREG	
		;movlw    'A' 
		;movwf    TXREG
		;    nop
f_inte		   
		
	    movf	status_temp,w
	    movwf	STATUS	
	    movf	w_temp,w
	    Banksel	INTCON	
	    bcf		INTCON,TMR0IF    
	

	    
	    retfie
	  init_compteur	movlw	.15
movwf	compteur
return
	
; configuration du port B en sortie (4LED)

	banksel TRISB		; port B en sortie
	clrf	TRISB		
	banksel PORTB		;Clear PORTC
	clrf	PORTB		
	
	; configuration de l'ADC
	
	banksel ADCON1
	movlw	B'00001110'	;Left justify,1 analog channel
	movwf	ADCON1		;VDD and VSS references

	banksel ADCON0	
	movlw	B'01000001'	;Fosc/8, A/D enabled
	movwf	ADCON0

	
	banksel	PIE1
	bsf	PIE1,RCIE
	
	banksel	INTCON	
	bsf	INTCON,GIE
	bsf	INTCON,PEIE
	bsf	INTCON,TMR0IE

	call    init_compteur

start	bsf 	ADCON0,GO	; demarrage de la conversion
non		BTFSC	ADCON0,GO	; attendre la fin de conversion
		goto	non
;oui		;swapf	ADRESH,W       ; quel est le role de cette instruction ???
		;movwf	PORTB	; ecriture sur le port B (affichage sur les LEDs
		movf ADRESH,stock_AdresH
		goto start			; boucler sur la procedure de lecture


     
 	org	0x100
	nop
	
Ascii_R		DECTECT_cara	;movfw	Ascii_R
		;movwf	Ascii_temp
		MOVLW	0x72
		SUBWF	Ascii_R,f
		BTFSC	STATUS,Z	
		GOTO	cara_r
		ADDWF	Ascii_R,f
		MOVLW	0x61
		SUBWF	Ascii_R,f
		BTFSC	STATUS,Z	
		GOTO	cara_a
		ADDWF	Ascii_R,f
		MOVLW	0x64
		SUBWF	Ascii_R,f
		BTFSC	STATUS,Z	
		GOTO	cara_d
		ADDWF	Ascii_R,f
		movlw	0xFF
		movwf	cara
		return
		
cara_r		movlw	b'00000001'
		movwf	cara
		return
cara_a		movlw	b'00000010'
		movwf	cara
		return
cara_d		movlw	b'00000100'
		movwf	cara
		return		

USART		banksel TXSTA	
		movlw   B'00100100'
		movwf	TXSTA
		banksel	SPBRG
		movlw   .25  
		movwf   SPBRG	
		banksel RCSTA
		movlw   B'10010000'
		movwf   RCSTA
		
		
		
modeA		movlw	b'00000001'
		movwf	mode
		return
		
modeR		movlw	b'00000010'
		movwf	mode
		return	
		
changement_mode	btfsc	cara,1
		call	modeA
		btfsc	cara,0
		call	modeR
		return
	
ASCII		
	

		
	
print		call process
		movf Converti,w
		movwf stock
		call Q_dix
finp		return
	
process		movf ADRESH,Converti
		movf ADRESH,D
retest		movlw 0x33 
		incf Q,f
		subwf D,f
		btfsc STATUS,z
		goto finp
		btfsc STATUS,c ;si c=0 c'est à dire que notre resultat est négative
		goto retest
		decf Q,f 
		addwf D,R
		return
Qotdec		incf Q_dix,f	
		movlw 0x5
		subwf R,f
		btfsc STATUS,z
		goto testeurdec
		btfsc STATUS,c
		goto Qotdec
		decf Q_dix,f
testeurdec
		btfsc STATUS,z
		decf Q_dix,f 
		return	

	
tempo	bcf	INTCON,2
	movlw	.14
	movwf	compteur
bouc	call	t_local
	DECFSZ	compteur
	goto	bouc
	return
	
t_local	btfss	INTCON,TMR0IF
	GOTO	t_local
	bcf	INTCON,TMR0IF	
	RETURN
Loop1	decfsz COUNT1,1 ;Subtract 1 from 255
	goto   Loop1 
Loop2	decfsz COUNT2,1 
	goto   Loop1
	
	return
	
	

	
	
	
	
	END



     

		end	; du programme (directive d'assemblage)

	