; Copyright (C) 2025 iProgramInCpp

.segment "PRG_MAIN"

; ** SUBROUTINE: far_call2
; desc: Does a far call in a slightly slower, but slimmer way
; parameters:
;     X - The low byte of the address
;     Y - The high byte of the address
;     A - The bank to load
far_call2:
	stx farcalladdr
	sty farcalladdr+1
	sta farcalladdr+2
	
	jml [farcalladdr]

; ** SUBROUTINE: soft_nmi_on
; desc: Enable racey NMIs in software.
; purpose: Most of the NMI routine is racey against the main thread. However, we want to run
;          audio every frame regardless of lag. This is why we block racey NMIs in software.
; clobbers: A
; call with JSL
soft_nmi_on:
	lda #1
	sta nmienable
	rtl

; ** SUBROUTINE: soft_nmi_off
; desc: Disable racey NMIs in software.
; clobbers: A
; call with JSL
soft_nmi_off:
	lda #0
	sta nmienable
	rtl

; ** SUBROUTINE: nmi_wait
; arguments: none
; clobbers: A
; call with JSL
nmi_wait:
	lda nmicount
:	cmp nmicount
	beq :-
	rtl

; ** SUBROUTINE: vblank_wait
; arguments: none
; clobbers: A
; call with JSL
vblank_wait:
:	bit hvbjoy
	bpl :-
	rtl

; ** SUBROUTINE: ppu_nmi_on
; arguments: none
; clobbers: A
; call with JSL
ppu_nmi_on:
	lda #%10000001  ; NMI enabled, joypad auto-read
	sta nmitimen
	rtl

; ** SUBROUTINE: com_clear_oam
; desc: Clears OAM.
; must call with JSL
com_clear_oam:
	ldx #0
	txa
	
	; clear the high table - oam_putsprite (+oam_putsprite2) depend on
	; the high table being initted to zero
:	sta f:oam_table_hi, x
	inx
	cpx #32
	bne :-
	
	stz oam_wrhead
	stz oam_wrhead+1
	
	; then also set the Y coordinate to a high amount
	i16
	lda #$F0
	ldx #0
:	sta f:oam_table_lo+1, x
	inx
	inx
	inx
	inx
	cpx #512
	bne :-
	
	i8
	rtl

; ** SUBROUTINE: oam_putsprite
; ** SUBROUTINE: oam_putsprite2
; arguments:
;   a - attributes
;   x - extended attributes (sprite size, sign bit, applies only to oam_putsprite2)
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, y
; desc:      inserts a big sprite into OAM memory
; must call with JSL
oam_putsprite2:
	cpx #0
	beq oam_putsprite
	
	pha
	a16
	
	lda oam_wrhead
	
	; since oam_wrhead is a byte position ($000-$1FF), we need to shift it a bunch
	lsr
	lsr
	
	; now it's the sprite index, but we need to mess with it some more
	pha
	
	; first, get the in-byte position, multiply it by 4 and add the extended attribute bits
	and #3
	sta temp1
	txa
	asl
	asl	
	clc
	adc temp1
	tay
	
	pla
	lsr
	lsr
	tax
	a8
	
	; now, X is the byte to modify, and Y is the bit index to modify
	lda f:oam_table_hi, x
	ora oam_putsprite_table, y
	sta f:oam_table_hi, x
	
	pla

oam_putsprite:
	i16
	; 0 - X coord
	; 1 - Y coord
	; 2 - tile number
	; 3 - attributes + high bit of TN
	
	; store the attribute and tile number byte
	ldx oam_wrhead
	sta f:oam_table_lo+3, x
	tya
	sta f:oam_table_lo+2, x
	
	lda x_crd_temp
	sta f:oam_table_lo, x
	lda y_crd_temp
	sta f:oam_table_lo+1, x
	
	inx
	inx
	inx
	inx
	stx oam_wrhead
	
	i8
	rtl

oam_putsprite_table:
	.byte $00, $00, $00, $00
	.byte $01, $04, $10, $40
	.byte $02, $08, $20, $80
	.byte $03, $0C, $30, $C0

reset:
	sei
	cld
	clc
	xce
	
	ldx #$FF
	txs
	
	pea $0000
	pea $0000
	pld
	plb
	plb
	
	ai16
	
	; zero the CPU registers nmitimen through memsel
	; note: since A is 16 bits there are 2 bytes written
	stz nmitimen; and wrio
	stz wrmpya  ; and wrmpyb
	stz wrdivl  ; and wrdivh
	stz wrdivb  ; and htimel
	stz htimeh  ; and vtimel
	stz vtimeh  ; and mdmaen
	stz hdmaen  ; and memsel
	
	lda #$0080
	sta inidisp ; turn off screen (enable force blank)
	; ^ also sets obsel to 0
	
	stz oamaddl ; and oamaddrh
	stz bgmode  ; and mosaic
	stz bg1sc   ; and bg2sc
	stz bg3sc   ; and bg4sc
	stz vmaddl  ; and vmaddh
	stz w12sel  ; and w34sel
	stz wh0     ; and wh1
	stz wh2     ; and wh3
	stz wbglog  ; and wobjlog
	stz tm      ; and ts
	stz tmw     ; and tsw
	
	; disable color math
	lda #$0030
	sta cgwsel
	lda #$00E0
	sta coldata
	
	a8
	stz bg1hofs
	stz bg1hofs
	stz bg1vofs
	stz bg1vofs
	stz bg2hofs
	stz bg2hofs
	stz bg2vofs
	stz bg2vofs
	stz bg3hofs
	stz bg3hofs
	stz bg3vofs
	stz bg3vofs
	stz bg4hofs
	stz bg4hofs
	stz bg4vofs
	stz bg4vofs
	
	stz wobjsel
	
	; set up the color palette
	stz cgadd
	
	; set BG Mode to 1
	lda #1
	sta bgmode
	
	; for now, the VRAM will look as follows:
	; $0000 - Screen 0, 1, 2, 3
	; $4000 - Char Set
	
	lda #%00000000 ; address = $0000, no h mirroring, no v mirroring
	sta bg1sc
	
	lda #%00000010 ; address = $4000 >> 13 = $02
	sta bg12nba
	
	; perform DMA on channel 0 to transfer a zero byte into $0000 in VRAM
	lda #%00011001 ; pattern 1, transfer from A to B, A bus addr fixed after copy
	sta dmap(0)
	
	lda #<vmdatal
	sta bbad(0)
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain
	
	ldx #0
	stx vmaddl
	
	ldx #.loword(zero_byte)
	stx a1tl(0) ; and a1th(0)
	lda #<.hiword(zero_byte)
	sta a1b(0)
	ldx #$1000
	stx dasl(0) ; and dash(0)
	
	lda #1
	sta mdmaen
	
	; fill WRAM with zeroes using two 64kib fixed address DMA transfers to WMDATA.
	stz wmaddl
	stz wmaddm
	stz wmaddh
	
	lda #$08
	sta dmap(0)  ; fixed address transfer to a byte register
	
	lda #<wmdata
	sta bbad(0)
	
	ldx #.loword(zero_byte)
	stx a1tl(0)
	lda #.bankbyte(zero_byte)
	sta a1b(0)
	ldx #0
	sta dasl(0)
	
	; first 64K
	lda #1
	sta mdmaen
	
	; second 64K
	stx dasl(0)
	sta mdmaen
	
	; show BG1 in main screen
	lda #1
	sta tm
	
	; change to full 8 bit mode
	ai8
	
	ldy #gm_title
	sty gamemode     ; set title screen mode
	
	ldy #$ac
	sty rng_state    ; initialize rng seed
	ldy #$42
	sty rng_state+1
	
	; enable NMIs
	stz tempmaskover
	stz nmi_disable
	jsl ppu_nmi_on
	cli

; ** MAIN LOOP
main_loop:
	jsl soft_nmi_off
	jsl game_update
	jsl soft_nmi_on
	jsl nmi_wait
	bra main_loop

.include "update.asm"
.include "nmi.asm"

zero_byte:	.byte 0

no_int:
irq:
	rti

; ** SUBROUTINE: load_chr_page_8K
; desc: Loads a 4bpp CHR page to an address in VRAM. (in total, 8KB)
; parameters:
;     X/Y are 16 bits wide, A is 8 bits wide
;     X - Low Word of charset data
;     A - Bank byte
;     Y - Destination
; must call with JSL
; the screen must be blanked throughout the duration of the transfer
; also the data is like 8KB so force-blank is pretty much mandatory
.proc load_chr_page_8K
	; store that address into the A-bus address
	stx a1tl(0)
	sta a1b(0)
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain
	
	; put the address, shifted right by 1, in VMADDR
	a16
	tya
	lsr
	sta vmaddl
	
	; also load the size of the DMA transfer in question
	lda #$2000
	sta dasl(0)
	a8
	
	lda #<vmdatal
	sta bbad(0)
	
	; transfer pattern 1, A-bus side increment
	lda #1
	sta dmap(0)
	
	; go!
	;lda #1
	sta mdmaen
	rtl
.endproc

; ** SUBROUTINE: load_chr_page_4K
; desc: Loads a 2bpp CHR page to an address in VRAM. (in total, 4KB)
; parameters:
;     X/Y are 16 bits wide, A is 8 bits wide
;     X - Low Word of charset data
;     A - Bank byte
;     Y - Destination
; must call with JSL
; the screen must be blanked throughout the duration of the transfer
; also the data is like 8KB so force-blank is pretty much mandatory
.proc load_chr_page_4K
	; store that address into the A-bus address
	stx a1tl(0)
	sta a1b(0)
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain
	
	; put the address, shifted right by 1, in VMADDR
	a16
	tya
	lsr
	sta vmaddl
	
	; also load the size of the DMA transfer in question
	lda #$1000
	sta dasl(0)
	a8
	
	lda #<vmdatal
	sta bbad(0)
	
	; transfer pattern 1, A-bus side increment
	lda #1
	sta dmap(0)
	
	; go!
	;lda #1
	sta mdmaen
	rtl
.endproc

; ** SUBROUTINE: ppu_wrstring
; arguments:
;   x - low 16 bits of address (XY is 16 bits)
;   y - bank byte of address
;   a - length of string
; assumes:  - VMADDR was programmed to the PPU dest address
;             writes can happen (in vblank or rendering disabled)
;           - that the string does not straddle a page
;             boundary (256 bytes)
; desc:     copies a string from memory to the PPU, and puts an attr byte of 0 on them
; clobbers: VMADDR, all regs
; Must be called with JSL
.proc ppu_wrstring
	.i16
	stx wr_str_temp       ; store the address into a temporary
	sta wr_str_temp + 2   ; indirection slot
	tyx                   ; A cannot be incremented with 1 instruction
	ldy #$00
ppu_wrsloop:              ; so use X for that purpose
	lda [wr_str_temp], y  ; use that indirection we setup earlier
	sta vmdatal
	stz vmdatah
	iny
	dex
	bne ppu_wrsloop       ; if X != 0 print another
	rtl
.endproc

; ** SUBROUTINE: fade_in
; desc: Fades in.
; Must be called with JSL
.proc fade_in
	a8
	lda #32
	sta transtimer
@loop:
	jsl soft_nmi_on
	jsl nmi_wait
	jsl soft_nmi_off
	
	; (31 - transtimer) >> 1 determines the screen's brightness
	lda #32
	sec
	sbc transtimer
	lsr
	sta inidisp
	
	dec transtimer
	bne @loop
	
	lda #$0F
	sta inidisp
	rtl
.endproc

; ** SUBROUTINE: fade_out
; desc: Fades in.
; Must be called with JSL
.proc fade_out
	a8
	lda #31
	sta transtimer
@loop:
	jsl soft_nmi_on
	jsl nmi_wait
	jsl soft_nmi_off
	
	; transtimer >> 1 determines the screen's brightness
	lda transtimer
	lsr
	sta inidisp
	
	dec transtimer
	bne @loop
	
	lda #inidisp_OFF
	sta inidisp
	rtl
.endproc

; ** SUBROUTINE: load_palette
; desc: Loads a palette into CGRAM.
; parameters:
;    X - Address of the palette (16 bits)
;    A - Bank number (8 bits)
; Must be called with JSL
.proc load_palette
	stx a1tl(0)
	sta a1b(0)
	
	; load the DMA transfer's size - 512 Bytes
	lda #$2
	sta dash(0)
	stz dasl(0)
	
	stz cgadd
	
	lda #<cgdata
	sta bbad(0)
	
	; transfer pattern 0, A-bus side increment
	lda #0
	sta dmap(0)
	
	; go!
	lda #1
	sta mdmaen
	rtl
.endproc
