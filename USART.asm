list p=16f877

	; Include du fichier de description des définitions du 16f877
	include "p16f877.inc"
	; Start at the reset vector
	__CONFIG _FOSC_EXTRC & _WDTE_OFF & _PWRTE_OFF & _CP_OFF & _BOREN_ON & _LVP_ON & _CPD_OFF & _WRT_ON
	; pour utiliser timer0 , il faut fermer le timer watchdog
	;parce qu'il y a partie commune entre watchdog et timer0
	
	;timer0 realise par interpute
	
	COUNT1		EQU	0x71
	COUNT2		EQU	0x72
	COUNT3		EQU	0x73
	w_temp		EQU	0x74
	status_temp	EQU	0x75
	Ascii_R		EQU	0x76  
	
	compteur	EQU	0x77
	  
	org	0x000
	goto	configu
	nop
	
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
		movfw ADRESH
		movwf TXREG
		    nop
	
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

		
configu	org	0x100
	nop
	banksel TXSTA	;banksel TXSTA
	movlw   B'00100100'
	movwf	TXSTA
	banksel	SPBRG
	movlw   .25   ;baud rate =  9600bps
	movwf   SPBRG	;page 98 datasheet 16f87x
	
	banksel RCSTA
	movlw   B'10010000'
	movwf   RCSTA
	
	banksel	OPTION_REG 
	movlw   B'10000111'
	movwf	OPTION_REG
	
	
	;clrf	TRISB
	;banksel PORTB
	;clrf	PORTB 
	
	banksel	PIE1
	bsf	PIE1,RCIE
	
	banksel	INTCON	
	bsf	INTCON,GIE
	bsf	INTCON,PEIE
	bsf	INTCON,TMR0IE

	call    init_compteur
	


	
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


