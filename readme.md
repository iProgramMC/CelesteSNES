# Celeste SNES

This is the source code to iProgramInCpp's attempt to recreate  *[Celeste](https://www.celestegame.com)*
for the Super NES / Super Famicom.

Currently this is a massive work in progress. This means that the game may be
either:
- buggy,
- unstable,
- or downright broken.

**This project is based on https://github.com/iProgramMC/CelesteNES.**

## Why now?

I don't know. Just for fun I suppose.

This project will loosely follow [CelesteNES](https://github.com/iProgramMC/CelesteNES). This means that
CelesteNES will be updated more often.

## Discord Server

If you would like to chat about this game, you can do so in our Discord server: https://discord.gg/JWSUpfCubz

## Credits

- iProgramInCpp - Lead developer

- The members of the [NESdev discord server](https://discord.gg/VFnWZV8GWk) for miscellaneous help

- [Extremely OK Games](https://exok.com) for creating the wonderful game of [Celeste](https://www.celestegame.com)

- And you, for playing!

## Building

To build you will need the `cc65` toolchain installed (`ca65` and `ld65` are used), as well as a posix-compliant
`make` implementation.

Run the `make` command to build the ROM for the game.

### Warning

Certain package managers (Ubuntu, for example) will feature outdated builds of ca65 (`ca65 V2.18 - Ubuntu 2.19-1`
for example)  Unfortunately, it doesn't support all the features that this code base uses.

You will need to get a more up to date version. Compiling from source will work.

## Code Quality Warning

Because this is my second project written in 6502 assembly, code quality will vary. If you spot
anything unusual, let me know and I will fix it right up!

## License

This project has been neither created nor endorsed by the Celeste team.

The *Celeste* IP is owned by [Maddy Makes Games, Inc.](https://maddymakesgames.com).

The *graphics* (all \*.chr files, except d_font.chr) and *music* (`src/*/music`)
are under a **strictly non-commercial license**, meaning you **may not** use these
assets for **any** commercial purpose.

The game code (`src/`) is licensed under [the MIT license](license.txt).
