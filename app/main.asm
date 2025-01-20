;-------------------------------------------------------------------------------
; EELE 465, Project 1, 18 January 2025
; Gabriella Lord
;
; R14: Delay counter
; R15: Inner delay counter
;
; P1.0: output, red LED
; P6.6: output, green LED
;-------------------------------------------------------------------------------
			.cdecls C,LIST,"msp430.h"		; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
            .global __STACK_END
            .sect   .stack                  ; Make stack linker segment ?known?

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT

;-------------------------------------------------------------------------------
; Initialize
;-------------------------------------------------------------------------------
init:
    ; Configure LED1 (P1.0)
    bic.b	#BIT0, &P1SEL0
	bic.b	#BIT0, &P1SEL1
    bic.b   #BIT0,&P1OUT            ; Clear P1.0 output
    bis.b   #BIT0,&P1DIR            ; P1.0 output

    ; Configure LED2 (P6.6)
    bic.b	#BIT6, &P6SEL0
	bic.b	#BIT6, &P6SEL1
    bic.b   #BIT6,&P6OUT            ; Clear P1.0 output
    bis.b   #BIT6,&P6DIR            ; P1.0 output

    ; Initialize registers
    mov.w   #00000h, R3
    mov.w   #00000h, R4
    mov.w   #00000h, R5
    mov.w   #00000h, R6
    mov.w   #00000h, R7
    mov.w   #00000h, R8
    mov.w   #00000h, R9
    mov.w   #00000h, R10
    mov.w   #00000h, R11
    mov.w   #00000h, R12
    mov.w   #00000h, R13
    mov.w   #00000h, R14
    mov.w   #00000h, R15

	;-- Setup Timer B0 to overflow every 1 second
	bis.w	#TBCLR, &TB0CTL					; Clear timers & dividers
	bis.w	#TBSSEL__ACLK, &TB0CTL			; Select ACLK (32768 Hz) as timer source
	mov.w	#0803h, &TB0CCR0				; Set timer compare value
	bis.w	#CNTL__12, &TB0CTL				; Choose 12-bit count length
	bis.w	#ID__2, &TB0CTL					; Set div-by-2 in first divider
	bis.w	#TBIDEX__8, &TB0EX0				; Set div-by-8 in second divider
	bis.w	#CCIE, &TB0CCTL0				; Enable CCR interrupt
	bic.w	#CCIFG, &TB0CCTL0				; Clear initial interrupt flag
    
    ; Disable high-z mode
	bic.b	#LOCKLPM5, &PM5CTL0

	; Enable global interrupts
	nop
	bis.b	#GIE, SR
	nop

	; Start the timer in upward counting mode
	bis.w	#MC__UP, &TB0CTL

;-------------------------------------------------------------------------------
; Main loop
;-------------------------------------------------------------------------------
main:
    mov.w   #0000Ah, R14		    ; Wait for 10 100-ms cycles (1 s)
    call	#blinkRed			    ; Blink the red LED once
    jmp     main                    ; Repeat forever
;--End Main-----------------------------------------------------------------------------


;-------------------------------------------------------------------------------
; Blink the Red LED
;-------------------------------------------------------------------------------
blinkRed:
    call    #delay
    xor.b   #BIT0,&P1OUT            ; Toggle P1.0 every 1s
    
    ret

;--End blinkRed-----------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Delay loop
;-------------------------------------------------------------------------------
delay:
    mov.w   #088F6h,R15             ; Initialize inner loop counter for 100 ms delay
L1:
    dec.w   R15                     ; Decrement inner loop counter
    jnz     L1                      ; Inner loop is not done; keep decrementing
            
    dec.w   R14                     ; Inner loop is done; decrement outer loop counter
    jnz     delay                   ; Outer loop is not done; keep decrementing

    ret                             ; Outer loop is done

;--End Delay-----------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------

;-- Timer B0 ISR (blink green LED) ---------------------------------------------
toggleGreen:
	xor.b	#BIT6, &P6OUT					; Toggle green LED (P6.6)
	bic.w	#CCIFG, &TB0CCTL0				; Clear interrupt flag
	reti
;-- End Timer B0 ISR -----------------------------------------------------------

;-- End ISRs --------------------------------------------------------------------


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
			.global	__STACK_END
			.sect	.stack

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   RESET_VECTOR            ; MSP430 RESET Vector
            .short  RESET

            .sect	".int43"				; TB0CCR0 Interrupt
			.short	toggleGreen

            .end
