level0_w_init:
	.byte 0			; room left offset
	.byte 0, 144	; player spawn X/Y
	.addr level0_r1
level0_w_r1_to_r2:
	.byte 0			; room left offset
	.byte 0, 176	; player spawn X/Y
	.addr level0_r2
level0_w_r2_to_r1:
	.byte 24			; room left offset
	.byte 240, 160	; player spawn X/Y
	.addr level0_r1
level0_w_r2_to_r3:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.addr level0_r3
level0_w_r3_to_r2:
	.byte 28			; room left offset
	.byte 240, 96	; player spawn X/Y
	.addr level0_r2
level0_w_r3_to_r4:
	.byte 0			; room left offset
	.byte 0, 160	; player spawn X/Y
	.addr level0_r4
level0_w_r4_to_r3:
	.byte 4			; room left offset
	.byte 240, 128	; player spawn X/Y
	.addr level0_r3
