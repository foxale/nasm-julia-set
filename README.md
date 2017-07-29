# nasm-julia-set

Julia set generator for x86-64 in NASM.

https://pl.wikipedia.org/wiki/Zbi%C3%B3r_Julii

![Screenshot](https://image.ibb.co/hset75/julia_set_generator.png)

## Features

- Zooming in and out on mouse click
- Centering, also on mouse click 
- Fancy coloring

## Dependencies

- [NASM][nasm], with support for `elf64` output format
- Linker capable of emulating `elf64`
- Linux / GNU x64
