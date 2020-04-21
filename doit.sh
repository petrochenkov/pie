#!/usr/bin/env bash

set -e

declare -A flags
flags["default"]=""
flags["no-pie"]="-fno-PIE -no-pie"
flags["pie"]="-fPIE -pie"
flags["static"]="-static"
flags["shared"]="-shared"
flags["shared-no-pie"]="-shared -fno-PIE -no-pie"
flags["shared-pie"]="-shared -fPIE -pie"
flags["shared-static"]="-shared -static"
flags["static-pie"]="-fPIE -static-pie"
flags["static-pie-emu"]="-fPIE -static -Wl,-pie,--no-dynamic-linker,-z,text"

aclang=/e/Distribs/android-ndk-r21/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang
agcc=/e/Distribs/android-ndk-r17c-aarch64-21/bin/aarch64-linux-android-gcc.exe
areadelf=/e/Distribs/android-ndk-r21/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android-readelf.exe

for elf in default no-pie pie static shared shared-no-pie shared-pie shared-static; do
    # clang
    $aclang main.c -fuse-ld=lld -o $elf ${flags[$elf]} -v 2>$elf.out
    file $elf >$elf.file
    $areadelf -a $elf > $elf.readelf
    # gcc
    $agcc main.c -o $elf-gcc ${flags[$elf]} -v 2>$elf-gcc.out
    file $elf-gcc >$elf-gcc.file
    $areadelf -a $elf-gcc > $elf-gcc.readelf
done

for elf in static-pie; do
    # clang
    $aclang main2.c -fuse-ld=lld -o $elf ${flags[$elf]} -v 2>$elf.out
    file $elf >$elf.file
    $areadelf -a $elf > $elf.readelf
done

for elf in static-pie-emu; do
    # clang
    $aclang main.c -fuse-ld=lld -o $elf ${flags[$elf]} -v 2>$elf.out
    file $elf >$elf.file
    $areadelf -a $elf > $elf.readelf
done
