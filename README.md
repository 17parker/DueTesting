#The Gamedue color is back in a new repo with a horrible name! (I got a new computer, and I was having a lot of trouble with my debugger for some reason. Turns out, it was something with the solution files and it was easier to create an entire new project & repo)

The goal is to have the board run a game directly from an official cart via its 8-bit memory bus and 16 address pins. At the moment, it reads from the cartridge, it can dump the contents, and only a fraction of the opcodes is successfully interpreted.

Each of the gameboy's opcodes and its memory mapped I/O needs to be interpreted. The gameboy's CPU registers, RAM bank and VRAM bank need to be simulated. 

There are tricks to "bundle" multiple opcodes into the same case, which would have been cleaner and probably easier, too. I opted to use computed gotos and a jump table. This is an educational project, so I am more focused on implementing it a certain way. Otherwise, I'd just be copying something someone has already done. The sam3x8e lacks dedicated video and sound controllers, so the performance is going to be pretty bad.

There are many instructions that perform operations on registers without storing the result (they only update condition flags), and most efficient way to handle these cases are by inlining the ARM assembly equivalents (TST, TEQ, CMP, etc.) and getting the flags directly from the microcontroller's Application Program Status Register (APSR).

My only way of debugging is by printing data out over Serial, so I added ways to print instructions (and arguments) as it runs, dump the emulated stack, print the current values of each register, and so on. The program can be verified by comparing its output to a debugger in a known-working emulator on a PC.
