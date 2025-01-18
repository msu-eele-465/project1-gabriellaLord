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
    
    bic.w   #LOCKLPM5,&PM5CTL0       ; Unlock I/O pins

    ; Initialize registers
    mov.w   #00000h, R14
    mov.w   #00000h, R14

;-------------------------------------------------------------------------------
; Main loop
;-------------------------------------------------------------------------------
main:
    mov.w   #0000Ah, R14		    ; Wait for 1 100-ms cycles (2 s)
    call	#blinkRed			; Blink the red LED once
    jmp     main
;--End Main-----------------------------------------------------------------------------


;-------------------------------------------------------------------------------
; Blink the Red LED
;-------------------------------------------------------------------------------
blinkRed:
    xor.b   #BIT0,&P1OUT            ; Toggle P1.0 every 1s
    call    #delay

;--End blinkRed-----------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Delay loop
;-------------------------------------------------------------------------------
delay
    mov.w   #088F6h,R15              ; Delay to R15
L1
    dec.w   R15                     ; Decrement R15
    jnz     L1                      ; Delay over?
            
    dec.w   R14
    jnz     delay

    jmp     main                    ; Again
    NOP

;--End Delay-----------------------------------------------------------------------------



;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   RESET_VECTOR            ; MSP430 RESET Vector
            .short  RESET                   ;
            .end
