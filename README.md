The Gamedue color is back in a new repo with a horrible name! (I got a new computer, and I was having a lot of trouble with my debugger for some reason. Turns out, it was something with the solution files and it was easier to create an entire new project & repo)

The goal is to have the board run a game directly from an official cart via its 8-bit memory bus and 16 address pins. At the moment, it reads from the cartridge, it can dump the contents, and only a fraction of the opcodes are successfully interpreted.

It needs to run fast, and I started off using a lot of inline assembly mixed with C++. But at some point, I had so much inline assembly that it was easier to just write the entire thing in assembly. It was a lot easier to learn assembly than it was to wrestle with the compiler while using inline assembly.

There are a lot of register shenanigans that go against a few conventions that the compiler likes to adhere to, which made debugging a nightmare. Many values are never stored and are only ever contained in registers. At the moment, 9 of the 13 registers have a dedicated purpose, like holding a jump table address or the emulated program counter (there are 16 total but SP, LR and PC are left alone).
