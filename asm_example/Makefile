all: example_test.bin example_speed.bin

example_test.elf: example.s example_test.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ example.s example_test.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)

example_speed.elf: example.s example_speed.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ example.s example_speed.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)

include ../common/make.mk
