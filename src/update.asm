; Copyright (C) 2025 iProgramInCpp

gamemodes_LO:
	.byte 0;<gamemode_game
	.byte <gamemode_title
	.byte 0;<gamemode_titletr
	.byte 0;<gamemode_overwd
	.byte 0;<gamemode_prologue
	
gamemodes_HI:
	.byte 0;>gamemode_game
	.byte >gamemode_title
	.byte 0;>gamemode_titletr
	.byte 0;>gamemode_overwd
	.byte 0;>gamemode_prologue

gamemodes_BK:
	.byte 0;.bankbyte(gamemode_game)
	.byte .bankbyte(gamemode_title)
	.byte 0;.bankbyte(gamemode_titletr)
	.byte 0;.bankbyte(gamemode_overwd)
	.byte 0;.bankbyte(gamemode_prologue)

; ** SUBROUTINE: jump_engine
; desc: Jumps to the address corresponding to the current game mode.
; call with JSL
jump_engine:
	ldx gamemode
	lda gamemodes_LO, x
	sta temp1
	lda gamemodes_HI, x
	sta temp1+1
	lda gamemodes_BK, x
	sta temp1+2
	jml [temp1]

; ** SUBROUTINE: _rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
; credits:   https://www.nesdev.org/wiki/Random_number_generator#Overlapped
; call with JSR
.proc _rand
seed := rng_state
	lda temp11
	pha
	
	lda seed+1
	sta temp11 ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0 ; recombine with original low byte
	sta seed+1
	; compute seed+0 ($39 = %111001)
	lda temp11 ; original high byte
	sta seed+0
	asl
	eor seed+0
	asl
	eor seed+0
	asl
	asl
	asl
	eor seed+0
	sta seed+0
	
	pla
	sta temp11
	
	lda seed+0
	rts
.endproc

; ** SUBROUTINE: rand
; arguments: none
; clobbers:  a
; returns:   a - the pseudorandom number
; desc:      generates a pseudo random number
; credits:   https://www.nesdev.org/wiki/Random_number_generator#Overlapped
; call with JSL
rand:
	jsr _rand
	rtl

; ** SUBROUTINE: rand_m2_to_p1
; desc: Gets a random value between [-2, 1]
; call with JSL
rand_m2_to_p1:
	ldx #0
	jsr _rand
	and #3
	sec
	sbc #2
	bpl :+
	ldx #$FF
:	stx temp5
	rtl

; ** SUBROUTINE: rand_m1_to_p2
; desc: Gets a random value between [-1, 2]
; call with JSL
rand_m1_to_p2:
	ldx #0
	jsr _rand
	and #3
	sec
	sbc #1
	bpl :+
	ldx #$FF
:	stx temp5
	rtl

.include "weather.asm"

; ** SUBROUTINE: game_update
; arguments: none
; clobbers: all registers
game_update:
	jsl com_clear_oam    ; clear OAM
	jsl jump_engine      ; jump to the corresponding game mode
	;jmp com_calc_camera  ; calculate the visual camera position
	rtl
