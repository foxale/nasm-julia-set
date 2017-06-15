;nasm_loop.asm

section .data

section .text

global asmfunc
extern Width, Height
extern zoom
extern PaletteSize
extern C_X, C_Y
extern pixels
extern palette

asmfunc:
	push rbp
	mov rbp, rsp
	push rax
	push rbx
	push rcx
	push rdx
	
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	
	mov r9, [pixels]
	mov r10, [palette]
	
	;resolution_offset 
	mov ecx, [Width]
	sub ecx, [Height]
	sar ecx, 1
	
	mov bx, -1;442 ; y

out_loop:
	mov ax, -1 ;608 ; x
	
	add bx, 1
	
	; for (int y = 0; y < Height; ++y)
	cmp bx, [Height]
	je end
	
in_loop:
	add ax, 1
	
	;for (int x = 0; x < Width; ++x)
	cmp ax, [Width]
	je out_loop
	
	
def_z:
	cvtsi2sd xmm2, eax
	cvtsi2sd xmm3, ecx
	
	subsd 	 xmm2, xmm3
	addsd	 xmm2, xmm0
	movsx 	 r10, dword [Height]
	cvtsi2sd xmm10, r10
	divsd	 xmm2,  xmm10
	mov		 r8,   4
	cvtsi2sd xmm3, r8
	mulsd	 xmm2, xmm3
	mov		 r8,   2
	cvtsi2sd xmm3, r8
	subsd	 xmm2, xmm3
	movsd	 xmm3, [zoom]
	mulsd	 xmm2, xmm3
	
	
	cvtsi2sd xmm3, ebx
	addsd	 xmm3, xmm1
	divsd	 xmm3, xmm10
	mov		 r8,   4
	cvtsi2sd xmm4, r8
	mulsd	 xmm3, xmm4
	mov		 r8,   2
	cvtsi2sd xmm4, r8
	subsd	 xmm3, xmm4
	movsd	 xmm4, [zoom]
	mulsd	 xmm3, xmm4
	
	;xmm2 - real, xmm3 - imag
	
	mov dx, -1
	
	
cnt_loop:
	add dx, 1	;cnt 
	cmp dx, [PaletteSize]
	je colorPixels
	
	movsd xmm4, xmm2
	mulsd xmm4, xmm3
	
	mov		 r8,   2
	cvtsi2sd xmm5, r8
	mulsd	 xmm4, xmm5
	
	mulsd xmm2, xmm2
	mulsd xmm3, xmm3
	subsd xmm2, xmm3
	movsd xmm3, xmm4
	;Rex = xmm2, Imz = xmm3
	
	movsd	 xmm5, [C_X]
	movsd	 xmm6, [C_Y]
	

	
	addsd	 xmm2, xmm5
	addsd	 xmm3, xmm6
	;after z = z*z + c
	
	movsd	xmm5, xmm2
	movsd  	xmm6, xmm3
	mulsd	xmm5, xmm5
	mulsd  	xmm6, xmm6
	addsd	xmm5, xmm6
	sqrtsd	xmm5, xmm5
	
	mov r8, 2
	cvtsi2sd xmm6, r8
	
	comisd xmm5, xmm6
	jb cnt_loop
	
	
colorPixels:
	
	;cvtsd2si r8, xmm5
	;mov [r9], r8
	
	;mov [r9], dx
	mov r10, [palette]
	
	mov si, dx
	shl dx, 1	
	add dx, si
	add r10, rdx
	
	mov r12, 255
	mov [r9], r12
	add r9, 1
	
	add r10, 2
	mov r11, [r10]
	mov [r9], r11
	add r9, 1
	
	sub r10, 1
	mov r11, [r10]
	mov [r9], r11
	add r9, 1
	
	sub r10, 1
	mov r11, [r10]
	mov [r9], r11
	add r9, 1
	
	;add r9, 8

	jmp in_loop
	
end:
	pop rdx
	pop rcx
	pop rbx
	pop rax
	pop rbp
	
	ret
	
	

			;for (int y = 0; y < Height; ++y)
			;	for (int x = 0; x < Width; ++x)
			;	{
					
			;		std::complex<double> z( 
			;			1.0 * (x - resolution_offset + px_offset.x) / Height * 4.0 * zoom - 2.0 * zoom, 
			;			1.0 * (y + px_offset.y) 										/ Height * 4.0 * zoom - 2.0 * zoom
			;		);
					
			 
			;		cnt = 0;
			;		while (cnt < PaletteSize)
			;		{
			;			z = z * z + c;
			;			if (abs(z) > 2.0)
			;				break;
			;			++cnt;
			;		}
					
			;		pixels[y*Width + x] = 255 | ( palette[cnt][2] << 8) | ( palette[cnt][1] << 16) | ( palette[cnt][0] << 24);
					
