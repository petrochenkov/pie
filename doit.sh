#!/usr/bin/env bash

set -e

mingw=0
# mingw=1

if [ $mingw = 1 ]; then
    fPIE=""
else
    fPIE="-fPIE"
fi

declare -A flags
flags["default"]=""
flags["no-pie"]="-fno-PIE -no-pie"
flags["pie"]="$fPIE -pie"
flags["static"]="-static"
flags["shared"]="-shared"
flags["shared-no-pie"]="-shared -fno-PIE -no-pie"
flags["shared-pie"]="-shared $fPIE -pie"
flags["shared-static"]="-shared -static"
flags["static-pie"]="$fPIE -static-pie"
flags["static-pie-emu"]="$fPIE -static -Wl,-pie,--no-dynamic-linker,-z,text"
flags["static-pie-emu2"]="$fPIE -static -Wl,-pie"

aclang=/e/Distribs/android-ndk-r21/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang
agcc=/e/Distribs/android-ndk-r17c-aarch64-21/bin/aarch64-linux-android-gcc.exe
ald=/e/Distribs/android-ndk-r21/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android-ld.exe
areadelf=/e/Distribs/android-ndk-r21/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android-readelf.exe
dumpbin="/c/Program Files (x86)/Microsoft Visual Studio 14.0/VC/bin/amd64/dumpbin.exe"

if [ $mingw = 1 ]; then
    for elf in default no-pie pie static shared shared-no-pie shared-pie shared-static static-pie; do
        # clang
        clang main.c -fuse-ld=lld -o $elf ${flags[$elf]} -v 2>$elf.out
        file $elf.exe >$elf.file
        "$dumpbin" //ALL //RAWDATA:NONE $elf.exe > $elf.dumpbin
        # gcc
        gcc main.c -o $elf-gcc ${flags[$elf]} -v 2>$elf-gcc.out
        file $elf-gcc.exe >$elf-gcc.file
        "$dumpbin" //ALL //RAWDATA:NONE $elf-gcc.exe > $elf-gcc.dumpbin
    done

    exit 0
fi

for elf in default no-pie pie static shared shared-no-pie shared-pie shared-static static-pie-emu2; do
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
