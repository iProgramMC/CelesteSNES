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
	;jsr nmi_check_gamemodes
	
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
	lda joy1l
	sta p1_cont
	lda joy1h
	sta p1_cont+1
	
	rts
.endproc
