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
	
	i16
	
	; write the "PRESS START" text
	lda #$02
	sta vmaddh
	lda #$CB
	sta vmaddl
	ldx #.loword(logo_pressstart)
	lda #.bankbyte(logo_pressstart)
	ldy #9
	jsl ppu_wrstring
	
	; write iProgramInCpp's name
	lda #$03
	sta vmaddh
	lda #$28
	sta vmaddl
	ldx #.loword(logo_iprogram)
	lda #.bankbyte(logo_iprogram)
	ldy #15
	jsl ppu_wrstring
	
	; write "(C)2018 EXOK"
	lda #$03
	sta vmaddh
	lda #$4B
	sta vmaddl
	ldx #.loword(logo_exok)
	lda #.bankbyte(logo_exok)
	ldy #9
	jsl ppu_wrstring
	
	; write the "DEMO V1.XX" text.
	lda #$00
	sta vmaddh
	lda #$62
	sta vmaddl
	ldx #.loword(logo_version)
	lda #.bankbyte(logo_version)
	ldy #7
	jsl ppu_wrstring
	
	i8
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

logo_pressstart:	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78
logo_iprogram:		.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E
logo_exok:			.byte $60,$61,$79,$7A,$00,$7B,$7C,$7D,$7E
logo_version:		.byte $20,$21,$22,$23,$24,$25,$26
