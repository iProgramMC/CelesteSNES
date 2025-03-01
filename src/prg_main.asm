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

; ** SUBROUTINE: ppu_nmi_on
; arguments: none
; clobbers: A
; call with JSL
ppu_nmi_on:
	lda #%10000001  ; NMI enabled, joypad auto-read
	sta nmitimen
	rtl

; ** SUBROUTINE: oam_putsprite
; arguments:
;   a - attributes
;   y - tile number
;   [x_crd_temp] - y position of sprite
;   [y_crd_temp] - y position of sprite
; clobbers:  a, y
; desc:      inserts a sprite into OAM memory
oam_putsprite:
	i16
	; 0 - X coord
	; 1 - Y coord
	; 2 - tile number
	; 3 - attributes + high bit of TN
	
	; store the attribute and tile number byte
	ldx oam_wrhead
	sta oam_table_lo+3, x
	tya
	sta oam_table_lo+2, x
	
	lda x_crd_temp
	sta oam_table_lo, x
	lda y_crd_temp
	sta oam_table_lo+1, x
	
	inx
	inx
	inx
	inx
	stx oam_wrhead
	
	i8
	rtl

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
	
	; color format: 0bbbbbgggggrrrrr
	
	; black
	stz cgdata
	stz cgdata
	
	; dark gray
	lda #%11100111
	sta cgdata
	lda #%00011100
	sta cgdata

	; med gray
	lda #%11101111
	sta cgdata
	lda #%00111101
	sta cgdata
	
	; white
	lda #%11111111
	sta cgdata
	lda #%01111111
	sta cgdata
	
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
	
	; perform DMA on channel 0 to transfer our char set into memory
	; bbad and vmain remain the same
	
	lda #%00000001 ; pattern 1, transfer from A to B, increment A bus addr after copy
	sta dmap(0)
	
	; we want to write the char set to $4000
	ldx #$4000>>1
	stx vmaddl
	
	ldx #.loword(charset)
	stx a1tl(0) ; and a1th(0)
	lda #<.hiword(charset)
	sta a1b(0)
	ldx #.loword(charset_end-charset)
	stx dasl(0) ; and dash(0)
	
	; and go !
	lda #1
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
