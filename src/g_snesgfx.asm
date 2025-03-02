; Copyright (C) 2025 iProgramInCpp

.ifdef SNES

.proc gm_load_level_graphics
	i16
	a8
	
	ldx bg_bk1_addr
	ldy #BACKGROUND_BANK_1
	lda bg_bk1_addr+2
	jsl load_chr_page_8K
	
	ldx bg_bk2_addr
	ldy #BACKGROUND_BANK_2
	lda bg_bk2_addr+2
	jsl load_chr_page_8K
	
	i8
	rts
.endproc

.endif
