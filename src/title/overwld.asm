; Copyright (C) 2025 iProgramInCpp

gamemode_overwd_init_FAR:
	lda #0
	sta ow_sellvl
	
	;lda #0
	sta ow_lvlopen
	sta ow_slidetmr
	sta ow_iconoff
	sta ow_timer2
	sta camera_x
	sta camera_y
	sta camera_x_pg
	sta camera_y_hi
	sta scroll_x
	sta scroll_y
	sta scroll_flags
	sta irqtmp1
	;sta ppu_mask     ; disable rendering
	lda #inidisp_OFF
	sta inidisp
	lda #%10000000
	sta vmain
	
	jsl vblank_wait
	
gamemode_overwd_update_FAR:
	rtl

gamemode_overwd_update_NEAR:
	jmp gamemode_overwd_update_FAR

; ** GAMEMODE: gamemode_overwd
gamemode_overwd:
	lda #os_1stfr
	bit owldctrl
	bne gamemode_overwd_update_NEAR
	
	;jsr aud_reset
	
	jmp gamemode_overwd_init_FAR
