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

TARGET=ia64-hp-openvms
ROOT_PATH=$GNAT_VMS_ROOT_PATH
BUILDROOT=${ROOT_PATH}/builds/${GCC_VERSION}/${TARGET}-cross
PREFIX=/opt/local/${GCC_VERSION}/${TARGET}
export PATH=${ROOT_PATH}/utilities/binaries:${PATH}

gnatmake -P ${ROOT_PATH}/utilities/utilities.gpr

export LD_LIBRARY_PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/lib:$LD_LIBRARY_PATH
export PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:$PATH

rm -rf ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-cross

mkdir -p ${BUILDROOT}/src
cd ${BUILDROOT}/src

# unpack

rm -rf ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/
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
#


cd ${BUILDROOT}/src


mkdir -p BUILD/gcc-${GCC_FULL_VERSION}-cross
cd BUILD/gcc-${GCC_FULL_VERSION}-cross

which gcc
echo "confirm gcc ok"
read

#
#                Patch
#

utilities-main ${ROOT_PATH}/configurations/${TARGET}-cross/gcc-${GCC_FULL_VERSION}/src/gcc-${GCC_FULL_VERSION} ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION} TRUE

cp -p ${ROOT_PATH}/configurations/${TARGET}-cross/gcc-${GCC_FULL_VERSION}/src/gcc-${GCC_FULL_VERSION}/gcc/ada/s-vaflop-vms-ia64.adb ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION}/gcc/ada/

#
#                 Configure
#

CC=gcc ../../gcc-${GCC_FULL_VERSION}/configure --build=x86_64-linux-gnu --prefix=${PREFIX} --target=${TARGET} \
        --enable-languages=c,ada,c++ \
      --disable-shared --disable-threads \
      --disable-libmudflap --disable-libssp --disable-libstdcxx-v3 --disable-nls \
      --disable-libgomp --disable-multilib \
      --without-headers \
      --with-build-sysroot=${ROOT_PATH}/sysroots/${TARGET}/ \
      --with-gnu-ld --disable-lto --enable-sjlj-exceptions

#  History
#
# https://gcc.gnu.org/ml/gcc-help/2010-04/msg00264.html
# --enable-sjlj-exceptions
#
# --with-build-sysroot=/opt/local/ia64-hp-openvms/ia64-hp-openvms/


#
#                 all-gcc
#

  make all-gcc 2>&1 | tee all-gcc.log
echo "Press enter if everything is ok for [all-gcc], to continue the build"
read

sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin LD_LIBRARY_PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/lib:$LD_LIBRARY_PATH LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ make install-gcc 2>&1 | tee install-gcc.log"

echo "Press enter if everything is ok for [install-gcc]"
read


#
#                 all-target-libgcc
#

make all-target-libgcc 2>&1 | tee all-target-libgcc.log
echo "Press enter if everything is ok for [all-target-libgcc]"
read

sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin: make install-target-libgcc  2>&1 | tee install-target-libgcc.log"


#
#                 all-target-libada  
#

make all-target-libada 2>&1 | tee all-target-libada.log
# this first run allows to create the local files, for them to be patched below
#

# APPLY PATCHES
utilities-main ${ROOT_PATH}/configurations/${TARGET}-cross/gcc-${GCC_FULL_VERSION}/all-target-libada ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-cross TRUE

make all-target-libada 2>&1 | tee -a all-target-libada.log
# we rerun the command once the files are patched
#

echo "Press enter if everything is ok for [all-target-libada]"
read

sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin make install-target-libada  2>&1 | tee install-target-libada.log"

#
#                 all-gnattools  
#
make all-gnattools 2>&1 | tee -a all-gnattools.log

echo "Press enter if everything is ok for [all-gnattools]"
read

sudo cp ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-cross/gcc/gnatmake-cross ${PREFIX}/bin/${TARGET}-gnatmake
sudo cp ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-cross/gcc/gnatlink-cross ${PREFIX}/bin/${TARGET}-gnatlink
