#!/bin/bash

sys=$(uname -m)

# Required dependencies: bc bison flex libssl-dev u-boot-tools binutils gcc
DIR="$PWD"

configs=("am335x_evm_defconfig" "am335x_evm_defconfig_netboot")

if [ ! -f ./load.menuconfig ] ; then
    echo "Developers: to make changes: [touch load.menuconfig]"
fi

for config in "${configs[@]}"; do
    build_dir="build_${config}"
    config_dir="configs/${config}"
    
    mkdir -p "${build_dir}"
    
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O="${build_dir}" distclean
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O="${build_dir}" "${config}"
    
    if [ -f "load.menuconfig" ]; then
        make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O="${build_dir}" menuconfig
        make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- O="${build_dir}" savedefconfig
        cp -v "${build_dir}/defconfig" "${config_dir}"
    fi
    
    make ARCH=arm -j2 CROSS_COMPILE=arm-linux-gnueabihf- O="${build_dir}"
    cp -v "${build_dir}/u-boot.bin" "${build_dir}/"

done
