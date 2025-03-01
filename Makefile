# Copyright (C) 2025 iProgramInCpp

AS = ca65
CC = cc65
LD = ld65

#DEBUGSW=
DEBUGSW=-DDEBUG

.PHONY: clean

build: main.sfc

%.o: src/%.asm
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@ --listing "$(notdir $@).lst" $(DEBUGSW) -DSNES

main.sfc: layout main.o
	$(LD) --dbgfile $@.dbg -C $^ -o $@ -m $@.map

clean:
	rm -f main.sfc *.dep *.o *.dbg

include $(wildcard *.dep)
