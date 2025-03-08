The Gamedue color is back in a new repo with a horrible name! (I got a new computer, and I was having a lot of trouble with my debugger and it was easier to create an entire new project & repo). It is now a Gameboy emulator (not a Gameboy Color). The entire Gameboy's memory space (including unused areas) can fit in the Due's RAM, which simplifies some of the memory accesses. The Gameboy Color's memory space can't fit in the Due's RAM without extra logic. Also, the Due is probably not fast enough to run the original Gameboy, and transparency is an issue (which is supported on the GBC but not the GB. Developers would take advantage of the fact that the GB's display had a slow response time, so blinking a pixel quickly would cause it to "blend" with the background, simulating transparency).

The goal is to have the board run a game directly from an official cart via its 8-bit memory bus and 16 address pins. At the moment, it reads from the cartridge, it can dump the contents, and only a fraction of the opcodes are successfully interpreted.

I started off using a lot of inline assembly mixed with C++, but at some point, I had so much inline assembly that it was easier to just write the entire thing in assembly.

A longer document explaining everything is in the works and will be released when more progress on the project has been made.
