#!/bin/bash

sys=$(uname -m)

# Required dependencies: bc bison flex libssl-dev u-boot-tools binutils gcc
DIR="$PWD"

configs=("am335x_evm_defconfig" "am335x_evm_netboot_defconfig")

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
    
    make ARCH=arm -j2 CROSS_COMPILE=arm-linux-gnueabihf- O="${build_dir}" all
done

cp build_am335x_evm_defconfig/u-boot.img ../tftpboot/u-boot.img
cp build_am335x_evm_netboot_defconfig/u-boot.img ../tftpboot/u-boot-restore.img
cp build_am335x_evm_defconfig/MLO ../tftpboot/MLO
cp build_am335x_evm_netboot_defconfig/spl/u-boot-spl.bin ../tftpboot/u-boot-spl-restore.bin