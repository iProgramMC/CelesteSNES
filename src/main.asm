; Copyright (C) 2025 iProgramInCpp

; This file ties everything together.

.p816
.smart
.feature string_escapes
.feature line_continuations

.include "defines.asm"
.include "globals.asm"
.include "d_macros.asm"

.include "header.asm"
.include "prg_main.asm"
.include "prg_game.asm"
.include "prg_ttle.asm"


.segment "PRG_BANK1"
.segment "PRG_BANK2"
.segment "PRG_BANK3"
.segment "PRG_BANK4"
.segment "PRG_BANK5"
.segment "PRG_BANK6"
.segment "PRG_BANK7"
title_chr:
	.incbin "chr/b_title.chr"
lvl0_chr:
	.incbin "chr/b_lvl0.chr"
sprites_chr:
	.incbin "chr/sp_player.chr"

.include "level0/bank_0.asm"