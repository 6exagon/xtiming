CC = clang
CFLAGS = -O3
ASSEMBLER = as
LINKER = ld
LFLAGS = -lc

CSRC = $(wildcard xtiming/*.c)
ASMSRC = $(wildcard xtiming/*.s)
OBJ = $(patsubst xtiming/%.c,out/%.o,$(CSRC))
OBJ += $(patsubst xtiming/%.s,out/%.o,$(ASMSRC))

xtiming: build $(OBJ)
	$(LINKER) $(LFLAGS) -o build/xtime $(filter-out $<,$^)

build:
	mkdir build

out/%.o: xtiming/%.c out
	$(CC) $(CFLAGS) -c -o $@ $<

out/%.o: xtiming/%.s out
	$(ASSEMBLER) -o $@ $<

out:
	mkdir out

clean:
	rm -rf build out