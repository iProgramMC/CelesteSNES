; Copyright (C) 2025 iProgramInCpp

; ** NMI
.proc nmi
	inc nmicount
	bit rdnmi
	ai8
	pha
	
	lda nmi_disable
	bne dontRunNmi
	
	phx
	phy
	
	lda nmienable
	beq onlyAudioPlease  ; if NMIs are softly disabled, then ONLY run audio
	
	;jsr nmi_check_flags
	jsr nmi_check_gamemodes
	
	; I'd just inline this but I have no space!
	;jsr reset_ppuaddr
	
	;jsr nmi_scrollsplit
	jsr oam_dma_and_read_cont
	;jsr nmi_anims_update
	
	lda scrollsplit
	beq onlyAudioPlease
	
	;jsr gm_calc_camera_split
	
onlyAudioPlease:
	; Enable interrupts to run audio. Sometimes, running audio takes a long time
	; (25 scanlines+!), so let it be interrupted, since our IRQs won't mess with it.
	cli
	;jsr aud_run
	
dontRunAudio:
	ply
	plx
dontRunNmi:
	pla
	rti
.endproc

.proc oam_dma_and_read_cont
	stz oamaddl
	stz oamaddh
	
	lda #0
	sta dmap(0) ; transfer from A to B Bus, increment A Bus address, 1 register write once
	
	lda #<oamdata
	sta bbad(0)
	
	lda #.lobyte(oam_table_lo)
	sta a1tl(0)
	lda #.hibyte(oam_table_lo)
	sta a1th(0)
	lda #.bankbyte(oam_table_lo)
	sta a1b(0)
	
	; 544 bytes
	lda #<544
	sta dasl(0)
	lda #>544
	sta dash(0)
	
	; TODO: Do multiple DMAs at once?
	; do the transfer now
	lda #1
	sta mdmaen
	
	; now read the controller
	lda joy1h
	sta p1_cont
	lda joy1l
	sta p1_cont+1
	
	rts
.endproc

nmi_check_gamemodes:
	lda gamemode
	beq @game
	cmp #gm_titletra
	beq @titleTra
	cmp #gm_overwld
	beq @overwld
	cmp #gm_prologue
	beq @prologue
@return:
	rts

@game:
	jmp @game_

@overwld:
	;lda #nc_updlvlnm
	;bit nmictrl
	;beq @return
	;eor nmictrl
	;sta nmictrl
	;jmp ow_draw_level_name
	
@prologue:
	;lda #nc_prolclr
	;bit nmictrl
	;beq @prol_dontClear
	;eor nmictrl
	;sta nmictrl
	;ldx pl_ppuaddr
	;ldy pl_ppuaddr+1
	;sty ppu_addr
	;stx ppu_addr
	
	;lda #0
	;ldy #32
;:	sta ppu_data
	;dey
	;bne :-
	
@prol_dontClear:
	;ldx pl_ppuaddr+1
	;beq @return       ; nothing to write
	;ldy pl_ppuaddr
	;stx ppu_addr
	;sty ppu_addr
	;ldx pl_ppudata
	;stx ppu_data
	;rts

@titleTra:
	lda fade_active
	bne :+
	lda tl_timer
	and #$08
	lsr
	lsr
	lsr
	asl
	tax
	
	lda #6
	sta cgadd
	
	lda f:alt_colors, x
	sta cgdata
	lda f:alt_colors+1, x
	sta cgdata
:	rts

@game_:
	lda stamflashtm
	beq @unFlash
	
	and #%00000100
	beq @unFlash
	
	; do flash
	lda #g2_flashed
	bit gamectrl2
	bne @returnUnFlash ; if already set
	
	ora gamectrl2
	sta gamectrl2
	
	; NOTE: hardcoded but I'm lazy
	;jsr @setPPUAddrTo3F11
	;lda #$26
	;sta ppu_data
	;lda #$16
	;sta ppu_data
	;lda #$06
	;sta ppu_data
	rts
	
@unFlash:
	lda gamectrl2
	and #g2_flashed
	beq @returnUnFlash
	
	; unset the bit
	eor gamectrl2
	sta gamectrl2
	; program the correct color
	; NOTE: hardcoded but I'm lazy
	;jsr @setPPUAddrTo3F11
	;lda #$37
	;sta ppu_data
	;lda #$14
	;sta ppu_data
	;lda #$21
	;sta ppu_data
	
@returnUnFlash:
	rts

@setPPUAddrTo3F11:
	;lda #$3F
	;sta ppu_addr
	;lda #$11
	;sta ppu_addr
	rts
