level0:
	.word $0000;level0_music	; music table
	.addr level0_banks	; list of banks for each room
	.byte $00	; environment type
	.byte $07	; warp count
	.addr level0_w_init
	.addr level0_w_r1_to_r2
	.addr level0_w_r2_to_r1
	.addr level0_w_r2_to_r3
	.addr level0_w_r3_to_r2
	.addr level0_w_r3_to_r4
	.addr level0_w_r4_to_r3
level0_banks:
	.byte .bankbyte(level0_w_init)
	.byte .bankbyte(level0_w_r1_to_r2)
	.byte .bankbyte(level0_w_r2_to_r1)
	.byte .bankbyte(level0_w_r2_to_r3)
	.byte .bankbyte(level0_w_r3_to_r2)
	.byte .bankbyte(level0_w_r3_to_r4)
	.byte .bankbyte(level0_w_r4_to_r3)
