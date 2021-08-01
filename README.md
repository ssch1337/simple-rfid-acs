Before building, you must install the [compiler ARM(gcc-arm-none-eabi)](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) and [openocd](http://openocd.org/)

## Build

```bash
make build
```

## Flash microcontroller

```bash
make run
```

## Debug

```bash
openocd -s ../scripts -f interface/stlink.cfg -f target/stm32f4x.cfg
```

## Size

```bash
make size
```

## Clean

```bash
make clean
```