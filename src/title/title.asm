; Copyright (C) 2025 iProgramInCpp

; ** SUBROUTINE: print_logo
; clobbers: a, x, y
; assumes:  video output disabled
print_logo:
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
	rts
	
gamemode_title_init_FAR:
	ai8
	lda #$00
	sta scroll_x     ; clear some fields
	sta scroll_y
	sta scroll_flags
	sta camera_x
	sta camera_y
	sta camera_x_pg
	sta camera_y_hi
	sta tl_cschctrl
	sta fadeupdrt+1
	
	lda #inidisp_OFF
	sta inidisp
	
	jsr print_logo   ; print the logo and the "PRESS BUTTON" text
	jsl tl_init_snow
	
	lda titlectrl
	ora #ts_1stfr
	sta titlectrl
	
	jsl fade_in

gamemode_title_update_FAR:
	jsl tl_update_snow
	jsl tl_render_snow
	
	lda #cont_start
	bit p1_cont
	beq tl_no_transition
	lda #gm_titletra
	sta gamemode
	lda #8
	sta tl_timer
	lda #tm_gametra
	sta tl_gametime
tl_no_transition:
	rtl

gamemode_titletr:
	jsl tl_update_snow
	jsl tl_render_snow
	
	ldx tl_gametime
	dex
	beq tl_owldswitch
	stx tl_gametime
	rtl

tl_owldswitch:
	lda #0
	sta fadeupdrt+1
	jsl fade_out
	
	lda #gm_overwld
	sta gamemode
	lda #0
	sta owldctrl
	lda #inidisp_OFF
	sta inidisp         ; disable rendering
	rtl

logo_pressstart:	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78
logo_iprogram:		.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E
logo_exok:			.byte $60,$61,$79,$7A,$00,$7B,$7C,$7D,$7E
logo_version:		.byte $20,$21,$22,$23,$24,$25,$26

title_palette:
	.word %0000000000000000 ; 0 - black
	.word %0111111111111111 ; 1 - white
	.word %0111001100101100 ; 2 - bright cyan ish
	.word %0110110110101100 ; 3 - blue
	.word %0001100010000100 ; 4 - grey
	.word %0111111101111001 ; 5 - slightly darker white
	.word %0111111111111111 ; 6 - another white, for the "press start" GUI

alt_colors:
	.word %0000001111111111 ; yellow
	.word %0000001111100000 ; green
