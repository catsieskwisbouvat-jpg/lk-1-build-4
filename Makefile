ASM=nasm
CC=gcc
CC16=/home/poes/lk/1.0/4/binl/wcc
LD16=/home/poes/lk/1.0/4/binl/wlink

SRC_DIR=src
TOOLS_DIR=tools
BUILD_DIR=build
ISO_DIR=$(BUILD_DIR)/iso

.PHONY: all floppy_image iso_image kernel bootloader clean always tools_fat

all: floppy_image iso_image tools_fat

floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/stage2.bin "::stage2.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img test.txt "::test.txt"


# CD-ROM Image (.iso) via El Torito Floppy Emulatie
$(BUILD_DIR)/main.iso: floppy_image
	mkdir -p $(ISO_DIR)
	cp $(BUILD_DIR)/main_floppy.img $(ISO_DIR)/
	genisoimage -R -b main_floppy.img -no-emul-boot -boot-load-size 4 -boot-info-table -o $(BUILD_DIR)/main.iso $(ISO_DIR)

# Bootloader
bootloader: stage1 stage2


stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR))

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR))


# Kernel
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

# Host Tools (compiled with GCC)
tools_fat: $(BUILD_DIR)/tools/fat

$(BUILD_DIR)/tools/fat: $(TOOLS_DIR)/fat/fat.c | always
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g -o $(BUILD_DIR)/tools/fat $(TOOLS_DIR)/fat/fat.c

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*

install_data:
	mcopy -i build/main_floppy.img test.txt ::TEST.TXT
	mdir -i build/main_floppy.img