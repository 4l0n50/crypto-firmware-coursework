.DEFAULT_GOAL := test
CROSS ?= arm-none-eabi-
CC := $(CROSS)gcc
OBJCOPY := $(CROSS)objcopy
ARCH := -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS := $(ARCH) -O3 -g3 -DSTM32F4 -fno-common -ffunction-sections -fdata-sections -Ilibopencm3/include
OUT := build/stm32
LIB := libopencm3/lib/libopencm3_stm32f4.a
LDSCRIPT := libopencm3/lib/stm32/f4/stm32f405x6.ld
LDFLAGS := $(ARCH) --static -nostartfiles -specs=rdimon.specs -T$(LDSCRIPT) -Wl,--gc-sections
LDLIBS := -Llibopencm3/lib -Wl,--start-group -lopencm3_stm32f4 -lc -lgcc -lrdimon -Wl,--end-group
CORE_SRC := $(wildcard chacha20/*.s chacha20/*.S)
CORE_OBJ := $(addprefix $(OUT)/,$(addsuffix .o,$(basename $(notdir $(CORE_SRC)))))
COMMON_OBJ := $(OUT)/chacha20.o $(OUT)/ecsw-stm32.o $(OUT)/stm32f4_wrapper.o $(CORE_OBJ)
.PHONY: test test-debug firmware lib clean
test:
	$(MAKE) -C qemu test SCHEME=chacha20 MODE=release
test-debug:
	$(MAKE) -C qemu test SCHEME=chacha20 MODE=debug
firmware: $(OUT)/chacha20-test.bin $(OUT)/chacha20-speed.bin
lib:
	PATH="$(CURDIR)/qemu/compat:$$PATH" $(MAKE) -C libopencm3 TARGETS=stm32/f4
$(OUT):
	mkdir -p $@
$(OUT)/%.o: chacha20/%.c | $(OUT)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@
$(OUT)/%.o: chacha20/%.s | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: chacha20/%.S | $(OUT)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: common/%.c | $(OUT)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@
$(OUT)/chacha20-test.elf: $(OUT)/chacha20.o $(OUT)/test.o $(filter-out $(OUT)/chacha20.o,$(COMMON_OBJ)) Makefile | lib
	$(CC) $(LDFLAGS) $(filter %.o,$^) $(LDLIBS) -o $@
$(OUT)/chacha20-speed.elf: $(OUT)/chacha20.o $(OUT)/speed.o $(filter-out $(OUT)/chacha20.o,$(COMMON_OBJ)) Makefile | lib
	$(CC) $(LDFLAGS) $(filter %.o,$^) $(LDLIBS) -o $@
$(OUT)/%.bin: $(OUT)/%.elf
	$(OBJCOPY) -Obinary $< $@
clean:
	rm -rf build
	$(MAKE) -C qemu clean
-include $(wildcard $(OUT)/*.d)
