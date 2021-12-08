list p=16f877

	; Include du fichier de description des définitions du 16f877
	include "p16f877.inc"
	; Start at the reset vector
	__CONFIG _FOSC_EXTRC & _WDTE_OFF & _PWRTE_OFF & _CP_OFF & _BOREN_ON & _LVP_ON & _CPD_OFF & _WRT_ON
	
	


