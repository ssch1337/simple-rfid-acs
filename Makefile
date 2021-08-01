TARGET = firmware
SRCFILES = main
SRCDIR = Src
BUILDDIR = build

OPTIMIZE = s
DEBUG = dwarf-2

ASRC = ./ST/Source/startup_stm32f411xe.s
FWLIB = lib
PHDRIVER=
CORESUPPORT=
DEVSUPPORT=
LINKERCMDFILE = ./ST/STM32F411RETx_FLASH.ld
DEVCLASS = STM32F411xE

INCLUDE += -I./CMSIS_5/CMSIS/Core/Include
INCLUDE += -I./$(SRCDIR)
INCLUDE += -I./ST/Source
INCLUDE += -I./ST/Include

CFLAGS += -fno-builtin
CFLAGS += -Wall
CFLAGS += -MD -MP -MT $(BUILDDIR)/$(*F).o -MF $(BUILDDIR)/dep/$(@F).mk
CFLAGS += -mthumb
CFLAGS += -mcpu=cortex-m4
CFLAGS += -g$(DEBUG) -O$(OPTIMIZE) -D$(DEVCLASS) $(INCLUDE) 
CFLAGS += -DGCC_ARMCM4 -DVECT_TAB_FLASH

ASMFLAGS += -ahls -mapcs-32

LFLAGS += -T $(LINKERCMDFILE)
LFLAGS += -nostartfiles
LFLAGS += -Wl,-Map -Wl,$(BUILDDIR)/$(TARGET).map
LFLAGS += -mthumb
LFLAGS += -mcpu=cortex-m4
LFLAGS += --specs=nosys.specs

CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
AR = arm-none-eabi-ar
AS = arm-none-eabi-as
CP = arm-none-eabi-objcopy
OD = arm-none-eabi-objdump
SZ = arm-none-eabi-size

frmname = $(BUILDDIR)/$(TARGET)
objs = $(addprefix $(BUILDDIR)/,$(addsuffix .o,$(SRCFILES)))

build: $(frmname).bin $(frmname).hex $(frmname).lss size
clean:
	rm -rf $(BUILDDIR)
run: $(frmname).bin
	openocd -f interface/stlink-v2.cfg -f target/stm32f4x.cfg -c "init" -c "reset halt" -c "flash write_image erase "$(frmname).bin" 0x08000000" -c "reset run" -c "exit"
$(frmname).bin: $(frmname).elf
	$(CP) -Obinary $(frmname).elf $(frmname).bin
$(frmname).hex: $(frmname).elf
	$(CP) -Oihex $(frmname).elf $(frmname).hex
$(frmname).lss: $(frmname).elf
	$(OD) -D -S $(frmname).elf > $(frmname).lss
size: $(frmname).elf
	$(SZ) $(frmname).elf
$(frmname).elf: $(objs) $(LINKERCMDFILE) $(BUILDDIR)/crt.o
	mkdir -p $(BUILDDIR)
	@ echo "..linking"
	$(LD) $(LFLAGS) -o $(frmname).elf $(BUILDDIR)/crt.o -Llib/ld $(objs)
$(BUILDDIR)/crt.o:
	mkdir -p $(BUILDDIR)
	$(AS) -o $(BUILDDIR)/crt.o $(ASRC)
	
$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	mkdir -p $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@
	
-include $(shell mkdir -p $(BUILDDIR)/dep) $(wildcard $(BUILDDIR)/dep/*)