# Local QEMU harness; upstream Makefiles, test.c and speed.c are unchanged.
.DEFAULT_GOAL := all
SCHEME ?= chacha20
MODE ?= release
CROSS ?= arm-none-eabi-
QEMU ?= qemu-system-arm
CC := $(CROSS)gcc
OBJDUMP := $(CROSS)objdump
SIZE := $(CROSS)size
VALID := chacha20
ifeq ($(filter $(SCHEME),$(VALID)),)
$(error SCHEME must be one of: $(VALID))
endif
ifeq ($(filter $(MODE),debug release),)
$(error MODE must be debug or release)
endif
ARCH := -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
OPT := $(if $(filter debug,$(MODE)),-O0,-O3)
CFLAGS := $(ARCH) $(OPT) -g3 -Wall -Wextra -fno-common -ffunction-sections -fdata-sections -MMD -MP
LDFLAGS := $(ARCH) -specs=rdimon.specs -nostartfiles -T mps2.ld -Wl,--gc-sections
OUT := build/$(MODE)/$(SCHEME)
ELF := $(OUT)/test.elf
ALL_SRC := $(wildcard ../$(SCHEME)/*.c ../$(SCHEME)/*.s ../$(SCHEME)/*.S)
SRC := $(filter-out ../$(SCHEME)/speed.c ../$(SCHEME)/example_speed.c,$(ALL_SRC))
NAMES := $(basename $(notdir $(SRC)))
OBJ := $(addprefix $(OUT)/,$(addsuffix .o,$(NAMES))) $(OUT)/platform.o $(OUT)/startup.o
.PHONY: all test test-all clean disasm debug-server
all: $(ELF)
$(OUT):
	mkdir -p $@
$(OUT)/%.o: ../$(SCHEME)/%.c | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: ../$(SCHEME)/%.s | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: ../$(SCHEME)/%.S | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/platform.o: support/platform.c | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/startup.o: support/startup.c | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(ELF): $(OBJ) mps2.ld Makefile
	$(CC) $(LDFLAGS) $(OBJ) -Wl,-Map,$(OUT)/test.map -Wl,--start-group -lc -lrdimon -lgcc -Wl,--end-group -o $@
	$(SIZE) $@
test: $(ELF)
	python3 run.py --qemu $(QEMU) --scheme $(SCHEME) --elf $(ELF)
test-all:
	$(MAKE) test SCHEME=chacha20 MODE=$(MODE)
disasm: $(ELF)
	$(OBJDUMP) -d -S $(ELF) > $(OUT)/test.disasm
	@echo "Disassembly: $(OUT)/test.disasm"
debug-server: $(ELF)
	$(QEMU) -M mps2-an386 -cpu cortex-m4 -display none -monitor none -serial none -net none -semihosting-config enable=on,target=native -kernel $(ELF) -S -gdb tcp:127.0.0.1:3333
clean:
	rm -rf build
-include $(OBJ:.o=.d)

