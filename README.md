# nasm-julia-set

Julia set generator for x86-64 in NASM and C++.

https://en.wikipedia.org/wiki/Julia_set

![Screenshot](https://image.ibb.co/hset75/julia_set_generator.png)

## Features

- Zooming in and out on mouse click
- Centering, also on mouse click 
- Fancy coloring

## Dependencies

- [NASM][nasm], with support for `elf64` output format
- Linker capable of emulating `elf64`
- Linux / GNU x64
