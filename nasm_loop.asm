;nasm_loop.asm
;asmfunc(double c_x, double c_y, double zoom, U32* pixels, int width, int height, int limit, int * palette, int x_offset/zoom, int y_offset/zoom)
;	 		XMM0	    XMM1	      XMM2	      RDI	  		RSI       RDX  	    RCX		    	R8				 XMM3 		XMM4			
;arguments in RDI, RSI, RDX, RCX, R8, and R9
; R9 - W-H / 2
; R10 - x, R11 - y;

section .text
global asmfunc


asmfunc:
	push rbp
	mov rbp, rsp	
	
	mov r9, rsi
	sub r9, rdx
	sar r9, 1
	
	cvtsi2sd xmm6, rdx
	
	mov r13, 2
	cvtsi2sd xmm9, r13
	
	mov r13, 4
	cvtsi2sd xmm10, r13
	
	mov r10, -1
	
y_loop:
	; r10 - x counter
	; r11 - y counter
	
	; for (int y = 0; y < Height; ++y)
	add r10, 1
	cmp r10, rdx
	je end
	
	mov r11, -1
	
x_loop:

	;for (int x = 0; x < Width; ++x)
	add r11, 1
	cmp r11, rsi
	je y_loop

def_z:
	; r12 = x - (width - height) / 2 
	mov r12, r11
	sub r12, r9
	; xmm5 = (x - (width - height) / 2 + x_offset/zoom ) / height
	cvtsi2sd xmm5, r12
	addsd xmm5, xmm3
	divsd xmm5, xmm6
	; xmm5 = (x - (width - height) / 2 + x_offset/zoom ) / height * 4.0
	mulsd xmm5, xmm10
	; xmm5 = ((x - (width - height) / 2 + x_offset/zoom ) / height * 4.0 - 2.0 ) * zoom
	subsd xmm5, xmm9
	mulsd xmm5, xmm2
	
	
	; xmm8 = y + y_offset/zoom
	cvtsi2sd xmm8, r10
	addsd xmm8, xmm4
	; xmm8 = ( y + y_offset/zoom ) / height * 4.0
	divsd xmm8, xmm6
	mulsd xmm8, xmm10
	; xmm7 = (2.0 - ( y + y_offset/zoom ) / height * 4.0 ) * zoom
	movsd xmm7, xmm9
	subsd xmm7, xmm8
	mulsd xmm7, xmm2

	; z.real() is in xmm5
	; z.imag() is in xmm7
	
	mov r12, -1
	
julia_iteration:
	add r12, 1
	cmp r12, rcx
	je colorPixel
	
	; Im(z*z+c) is in xmm8
	movsd xmm8, xmm5
	mulsd xmm8, xmm7
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
	mulsd xmm5, xmm5
	addsd xmm7, xmm5
	
	
	comisd xmm7, xmm10
	jb julia_iteration
	


colorPixel:
	mov r13, r8
	imul r12, 3
	
	add r13, r12
	mov [rdi], r13
	
	add r13, 1
	add rdi, 2
	mov [rdi], r13
	
	add r13, 1
	add rdi, 2
	mov [rdi], r13 
	
	add rdi, 2
	
	jmp x_loop


end:
	pop rbp
	ret
