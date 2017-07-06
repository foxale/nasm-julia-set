;nasm_loop.asm
;asmfunc(double c_x, double c_y, double zoom, U32* pixels, int width, int height, int limit, int * palette, int x_offset/zoom, int y_offset/zoom)
;	 		XMM0	    XMM1	      XMM2	      RDI	  		RSI       RDX  	    RCX		    	R8				 XMM3 		XMM4			
; R9 = (W-H)/2
; R10 = x counter, R11 = y counter;

section .text
global asmfunc


asmfunc:
	; registers that must be saved in 64bit Unix: RBX, RBP, R12-R15
	push rbp
	push r12
	push r13
	push r14
	mov rbp, rsp
	
	cvtpd2ps xmm0, xmm0
	unpcklps xmm0, xmm0
	unpcklps xmm0, xmm0
	
	cvtpd2ps xmm1, xmm1
	unpcklps xmm1, xmm1
	unpcklps xmm1, xmm1
	
	cvtpd2ps xmm2, xmm2
	unpcklps xmm2, xmm2
	unpcklps xmm2, xmm2
	
	cvtpd2ps xmm3, xmm3
	unpcklps xmm3, xmm3
	unpcklps xmm3, xmm3
	
	cvtpd2ps xmm4, xmm4
	unpcklps xmm4, xmm4
	unpcklps xmm4, xmm4

	
	; rcx = width / 4	
	shr rcx, 2
	
	; r9 = (W-H)/2
	mov r9, rsi
	sub r9, rdx
	sar r9, 1
	cvtsi2ss xmm11, r9
	unpcklps xmm11, xmm11
	unpcklps xmm11, xmm11
	
	
	; xmm6 = (double)Height 
	cvtsi2ss xmm6, rdx
	unpcklps xmm6, xmm6
	unpcklps xmm6, xmm6
	
	; a moze by tak addps ? 
	; xmm9 = 2.0 
	mov r13, 2
	cvtsi2ss xmm9, r13
	unpcklps xmm9, xmm9
	unpcklps xmm9, xmm9
	
	; xmm10 = 4.0
	mov r13, 4
	cvtsi2ss xmm10, r13
	unpcklps xmm10, xmm10
	unpcklps xmm10, xmm10
	
	xor r10, r10
	xor r11, r11
	
	; r10 - x counter
	; r11 - y counter

	; xmm12 - x'y
	
	; xmm12 = 0 1 2 3
	; zamiast tego sprawdzic hex i zrobic movq rax
	mov r13, 1
	cvtsi2ss xmm12, r13
	shufps xmm12, xmm12, 0x39
	
	shl r13, 1
	cvtsi2ss xmm12, r13
	shufps xmm12, xmm12, 0x39
	
	inc r13
	cvtsi2ss xmm12, r13
	shufps xmm12, xmm12, 0x39
	
	; xmm12+4, xmm13+1 NA KONIEC
	
def_z:
	; r12 = x - (width - height) / 2 
	shufps xmm5, xmm12, 0xE4
	subps xmm5, xmm11
	
	; xmm5 = (x - (width - height) / 2 + x_offset/zoom ) / height
	addps xmm5, xmm3
	divps xmm5, xmm6
	; xmm5 = (x - (width - height) / 2 + x_offset/zoom ) / height * 4.0
	mulps xmm5, xmm10
	; xmm5 = ((x - (width - height) / 2 + x_offset/zoom ) / height * 4.0 - 2.0 ) * zoom
	subps xmm5, xmm9
	mulps xmm5, xmm2
	
	
	; xmm8 = y + y_offset/zoom
	cvtsi2ss xmm8, rdx
	
	addss xmm8, xmm4
	; xmm8 = ( y + y_offset/zoom ) / height * 4.0
	divss xmm8, xmm6
	
	
	addss xmm8, xmm8
	addss xmm8, xmm8
	
	; xmm7 = (2.0 - ( y + y_offset/zoom ) / height * 4.0 ) * zoom
	movss xmm7, xmm9
	subss xmm7, xmm8
	mulss xmm7, xmm2
	shufps xmm7, xmm7, 0x00
	movaps xmm8, xmm7
	; z.real() is in xmm5
	; z.imag() is in xmm8
	
	mov r12, -1
	
julia_iteration:
	add r12, 1
	cmp r12, rcx
	je colorPixel
	
	; Im(z*z+c) is in xmm8
	movsd xmm7, xmm8
	mulsd xmm8, xmm5
	mulsd xmm8, xmm9
	addsd xmm8, xmm1
	
	; Re(z*z+c) is in xmm5
	mulsd xmm7, xmm7
	mulsd xmm5, xmm5
	subsd xmm5, xmm7
	addsd xmm5, xmm0
	
	; Re^2 + Im^2 is in xmm7
	movsd xmm7, xmm8
	mulsd xmm7, xmm7
	movsd xmm11, xmm5
	mulsd xmm11, xmm11
	addsd xmm7, xmm11
	
	comisd xmm7, xmm10
	jb julia_iteration
	
colorPixel:
	; n in r12
	; &palette in r13
	mov r13, r8
	imul r12, 3
	
	; set pointer to palette[n*3]
	add r13, r12
	
	; red
	mov r14b, [r13]
	mov [rdi], r14b
	
	; green
	add r13, 1
	add rdi, 1
	mov r14b, [r13]
	mov [rdi], r14b
	
	; blue
	add r13, 1
	add rdi, 1
	mov r14b, [r13]
	mov [rdi], r14b
	
	add rdi, 1
	
x_loop:
	;for (int x = 0; x < Width; ++x)
	add r10, 1
	cmp r10, rsi
	jl def_z

y_loop:
	; for (int y = 0; y < Height; ++y)
	mov r10, 0
	add r11, 1
	cmp r11, rdx
	jl def_z 

end:
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
