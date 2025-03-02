; Copyright (C) 2024 iProgramInCpp

level_table:
	.addr level0
	.addr level0;level1 ; 1
	.addr level0;level2 ; 2
	.addr level0;level3 ; 3
	.addr level0 ; 4
	.addr level0 ; 5
	.addr level0 ; 6
	.addr level0 ; 7

level_banks2:
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl1b
	.byte .bankbyte(level0);prgb_lvl2b
	.byte .bankbyte(level0);prgb_lvl3b
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl0a

level_banks_mus:
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl1c
	.byte .bankbyte(level0);prgb_lvl2e
	.byte .bankbyte(level0);prgb_lvl3a
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl0a
	.byte .bankbyte(level0);prgb_lvl0a

level_banks_spr:
	.byte 0;chrb_splvl0
	.byte 0;chrb_splvl1
	.byte 0;chrb_splvl2
	.byte 0;chrb_splvl0
	.byte 0;chrb_splvl0
	.byte 0;chrb_splvl0
	.byte 0;chrb_splvl0
	.byte 0;chrb_splvl0

level_palettes:
	.addr level0_palette
	.addr level0_palette;level1_palette
	.addr level0_palette;level2_palette
	.addr level0_palette;level3_palette
	.addr level0_palette
	.addr level0_palette
	.addr level0_palette
	.addr level0_palette

level_berry_counts:
	.byte 0
	.byte 20
	.byte 17 ; 18 -- the "Awake" section doesn't exist yet.
	.byte 25
	.byte 29
	.byte 31
	.byte 0
	.byte 47
	.byte 5

level_bg_data_lo:
	.byte <lvl0_chr
	.byte <lvl0_chr
	.byte <lvl0_chr
	.byte <lvl0_chr
	.byte <lvl0_chr
	.byte <lvl0_chr
	.byte <lvl0_chr
	.byte <lvl0_chr

level_bg_data_hi:
	.byte >lvl0_chr
	.byte >lvl0_chr
	.byte >lvl0_chr
	.byte >lvl0_chr
	.byte >lvl0_chr
	.byte >lvl0_chr
	.byte >lvl0_chr
	.byte >lvl0_chr

level_bg_data_bk:
	.byte ^lvl0_chr
	.byte ^lvl0_chr
	.byte ^lvl0_chr
	.byte ^lvl0_chr
	.byte ^lvl0_chr
	.byte ^lvl0_chr
	.byte ^lvl0_chr
	.byte ^lvl0_chr
