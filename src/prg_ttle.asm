; Copyright (C) 2025 iProgramInCpp

.segment "PRG_TTLE"

	.include "title/rle.asm"
	.include "title/title.asm"
	;.include "title/overwld.asm"
	;.include "title/prologue.asm"
	.include "title/titlescr.asm"
	;.include "title/mountain.asm"
	;.include "title/letter.asm"
	;.include "title/levelend.asm"
	;.include "title/chcomp.asm"

.ifdef SNES

gamemode_title:
	lda #ts_1stfr
	bit titlectrl                  ; might need to update the screen buffer
	bne gamemode_title_update_NEAR ; in PRG_TTLE
	
	; have to reset audio data because DPCM samples are loaded in at $C000
	; and we want to use that bank for title screen and overworld data.
	; We have 8K at our disposal.
	;jsr aud_reset
	
	jmp gamemode_title_init_FAR

gamemode_title_update_NEAR:
	jmp gamemode_title_update_FAR

.endif
