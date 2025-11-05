all: chacha20test.bin \
		 chacha20speed.bin


chacha20test.elf: chacha20.o chacha20.h test.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ test.o chacha20.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)

chacha20speed.elf: chacha20.o chacha20.h speed.o $(OBJS) $(LDSCRIPT)
		$(LD) -o $@ speed.o chacha20.o $(OBJS) $(LDFLAGS) -l$(LIBNAME)


include ../common/make.mk


