# Git Submodules
GBIT_LIB_C := \
	gbit/lib/tester.c \
	gbit/lib/ref_cpu.c \
	gbit/lib/inputstate.c \
	gbit/lib/disassembler.c

GBIT_OBJS = \
	gbit/lib/tester.o \
	gbit/lib/ref_cpu.o \
	gbit/lib/inputstate.o \
	gbit/lib/disassembler.o

# Flags
CFLAGS = -std=gnu99 -O2 -Wall -Wextra
LDFLAGS = -lm

# SDL
CFLAGS += -D ENABLE_LCD
CFLAGS += -D ENABLE_SOUND
CFLAGS += `sdl2-config --cflags`
LDFLAGS += `sdl2-config --libs`

# Control the build verbosity
ifeq ("$(VERBOSE)","1")
    Q :=
    VECHO = @true
else
    Q := @
    VECHO = @printf
endif

OUT ?= build
SHELL_HACK := $(shell mkdir -p $(OUT))

BIN = $(OUT)/emu $(OUT)/bench

all: $(GBIT_LIB_C) $(BIN)

OBJS = \
	apu.o \
	cpu.o \
	main.o

OBJS := $(addprefix $(OUT)/, $(OBJS))
deps := $(OBJS:%.o=%.o.d)

$(OUT)/%.o: %.c
	$(VECHO) "  CC\t$@\n"
	$(Q)$(CC) -o $@ $(CFLAGS) -c -MMD -MF $@.d $<

$(OUT)/emu: $(OBJS)
	$(VECHO) "  LD\t$@\n"
	$(Q)$(CC) -o $@ $^ $(LDFLAGS)

# Self-contained C/C++ profiler library for Linux
# https://github.com/cyrus-and/prof
prof.h:
	$(VECHO) "  Downloading the latest $@ ...\n"
	@wget -q https://raw.githubusercontent.com/cyrus-and/prof/master/prof.h

$(OUT)/cpu_instrs.h: tests/cpu_instrs.gb tests/rom2h.c
	$(VECHO) "  Generating C header from Blargg's Gameboy test ROM...\n"
	$(Q)$(CC) -o $(OUT)/rom2h tests/rom2h.c
	@$(OUT)/rom2h

$(GBIT_LIB_C):
	git submodule update --init
	touch $@

$(OUT)/bench: $(GBIT_OBJS) $(OUT)/cpu_instrs.h prof.h cpu.c bench.c gameboy.h
	$(VECHO) "  CC+LD\t$@\n"
	$(Q)$(CC) -DENABLE_LCD=0 -DGBIT -o $@ cpu.c bench.c $(GBIT_OBJS)

clean:
	$(RM) $(BIN) $(OBJS) $(GBIT_OBJS) $(deps)
distclean: clean
	$(RM) prof.h
	$(RM) -r roms
	$(RM) $(OUT)/rom2h $(OUT)/cpu_instrs.h

-include $(deps)

