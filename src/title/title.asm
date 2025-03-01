; Copyright (C) 2025 iProgramInCpp

gamemode_title_init_FAR:
	i16
	
	ldx #.loword(title_chr)
	ldy #$4000
	lda #.bankbyte(title_chr)
	jsl load_chr_page_8K
	
	ldx #.loword(title_palette)
	lda #.bankbyte(title_palette)
	jsl load_palette
	
	i8
	
	lda #%00000010 ; address = $4000 >> 13 = $02
	sta bg12nba
	
	; BGMODE 1
	lda #1
	sta bgmode
	
	; scroll coordinates
	lda #4
	sta bg1vofs
	stz bg1vofs
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain
	
	stz vmaddl
	stz vmaddh
	
	lda #<tscr_canvas
	ldx #>tscr_canvas
	ldy #.bankbyte(tscr_canvas)
	jsl nexxt_rle_decompress
	
	lda titlectrl
	ora #ts_1stfr
	sta titlectrl
	
	jsl fade_in
	
gamemode_title_update_FAR:
	rtl

gamemode_titletr:
	rtl

title_palette:
	.word $0000
	.word $7FFF             ; white
	.word %0111111101011010 ; bright cyan ish
	.word %0110110101100010 ; blue
	.word %0001110011100111 ; grey
