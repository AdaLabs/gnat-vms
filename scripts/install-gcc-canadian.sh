#!/bin/bash
#------------------------------------------------------------------------------
#--                                                                          --
#--                         GNAT-VMS-SCRIPTS                                 --
#--                                                                          --
#--          Copyright (C) 2015, AdaLabs Ltd & PIA-SOFER                     --
#--                                                                          --
#-- This is free software;  you can  redistribute it  and/or modify it under --
#-- terms of the  GNU General Public License as published  by the Free Soft- --
#-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
#-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
#-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
#-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
#-- for  more details.  You should have  received  a copy of the GNU General --
#-- Public License  distributed with GNAT; see file COPYING3.  If not, go to --
#-- http://www.gnu.org/licenses for a complete copy of the license.          --
#--                                                                          --
#-- Author: AdaLabs Ltd                                                      --
#--                                                                          --
#------------------------------------------------------------------------------


GCC_VERSION=4.7
GCC_FULL_VERSION=4.7.4

BUILD=x86_64-linux-gnu
HOST=ia64-hp-openvms
TARGET=ia64-hp-openvms
ROOT_PATH=$GNAT_VMS_ROOT_PATH
BUILDROOT=${ROOT_PATH}/builds/${GCC_VERSION}/${TARGET}-canadian
PREFIX=/opt/local/${GCC_VERSION}/canadian
export PATH=${ROOT_PATH}/utilities/binaries:${PATH}

gnatmake -P ${ROOT_PATH}/utilities/utilities.gpr

export LD_LIBRARY_PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/lib:$LD_LIBRARY_PATH
export PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:$PATH

mkdir -p ${BUILDROOT}/src
rm -rf ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-canadian




cd ${BUILDROOT}/src

cp ${ROOT_PATH}/tarballs/gcc-${GCC_FULL_VERSION}.tar.bz2 .
bunzip2 -d gcc-${GCC_FULL_VERSION}.tar.bz2
tar -xf gcc-${GCC_FULL_VERSION}.tar

MPC_VERSION=0.8.1
MPFR_VERSION=2.4.2
GMP_VERSION=4.3.2


cp ${ROOT_PATH}/tarballs/mpc-${MPC_VERSION}.tar.gz ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/
cp ${ROOT_PATH}/tarballs/mpfr-${MPFR_VERSION}.tar.bz2 ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/
cp ${ROOT_PATH}/tarballs/gmp-${GMP_VERSION}.tar.bz2 ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/

cd ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/
bunzip2 -d mpfr-${MPFR_VERSION}.tar.bz2
bunzip2 -d gmp-${GMP_VERSION}.tar.bz2
tar -xzf mpc-${MPC_VERSION}.tar.gz
tar -xf mpfr-${MPFR_VERSION}.tar
tar -xf gmp-${GMP_VERSION}.tar
ln -s mpc-${MPC_VERSION} mpc
ln -s gmp-${GMP_VERSION} gmp
ln -s mpfr-${MPFR_VERSION} mpfr


cd ${BUILDROOT}/src
mkdir -p BUILD/gcc-${GCC_FULL_VERSION}-canadian

cd BUILD/gcc-${GCC_FULL_VERSION}-canadian


which ia64-hp-openvms-gcc
echo "please confirm ia64-hp-openvms-gcc ok"
read

#
#                Patch
#
utilities-main ${ROOT_PATH}/configurations/${TARGET}-canadian/gcc-${GCC_FULL_VERSION}/base ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION} TRUE

utilities-main ${ROOT_PATH}/configurations/${TARGET}-canadian/gcc-${GCC_FULL_VERSION}/unwind-ia64-avoid-long-type ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION} TRUE

cp -p ${ROOT_PATH}/configurations/${TARGET}-cross/gcc-${GCC_FULL_VERSION}/src/gcc-${GCC_FULL_VERSION}/gcc/ada/s-vaflop-vms-ia64.adb ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/gcc/ada/

#
#                 Configure
#

CC=ia64-hp-openvms-gcc ../../gcc-${GCC_FULL_VERSION}/configure --build=${BUILD} --prefix=${PREFIX} --host=${HOST} --target=${TARGET} \
      --enable-languages=c,ada \
      --disable-shared --disable-threads  --disable-libstdcxx-v3 --enable-long-long \
      --disable-libmudflap --disable-libssp --disable-nls \
      --disable-libgomp --disable-multilib --disable-lto \
      --without-gnu-ld --with-build-sysroot=${ROOT_PATH}/sysroots/${TARGET} --enable-sjlj-exceptions

#
#                 all-gcc
#

make all-gcc  2>&1 | tee all-gcc.log

utilities-main ${ROOT_PATH}/configurations/${TARGET}-canadian/gcc-${GCC_FULL_VERSION}/all-gcc/ ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-canadian TRUE

make all-gcc  2>&1 | tee -a all-gcc.log



echo "Press enter if everything is ok, to process make install"
read
sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin:$PATH make install-gcc"

#
#                 all-target-libgcc
#

make all-target-libgcc 2>&1 | tee all-target-libgcc.log
echo "Press enter if everything is ok for [all-target-libgcc]"
read

sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin: make install-target-libgcc  2>&1 | tee install-target-libgcc.log"


make all-target-libada 2>&1 | tee all-target-libada.log

cp ${ROOT_PATH}/configurations/${TARGET}-cross/gcc-4.7.4/all-target-libada/gcc/ada/rts/s-oscon* gcc/ada/rts/

make all-target-libada 2>&1 | tee -a all-target-libada.log

echo "Press enter if everything is ok for [all-target-libada]"
read

sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin make install-target-libada  2>&1 | tee install-target-libada.log"

echo "Great, please build gnattools on target"

