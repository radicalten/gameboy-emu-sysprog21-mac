# Flags
CFLAGS = -std=gnu99 -O2 -Wall -Wextra
LDFLAGS = -lm

# SDL
CFLAGS += -D ENABLE_LCD
CFLAGS += -D ENABLE_SOUND
CFLAGS += `sdl2-config --cflags`
LDFLAGS += `sdl2-config --libs`

OUT ?= build
SHELL_HACK := $(shell mkdir -p $(OUT))

BIN = $(OUT)/emu $(OUT)/bench

all: $(BIN)

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

