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

TARGET=x86_64-linux-gnu
ROOT_PATH=$GNAT_VMS_ROOT_PATH
BUILDROOT=${ROOT_PATH}/builds/${GCC_VERSION}/${TARGET}-native
PREFIX=/opt/local/${GCC_VERSION}/${TARGET}
export PATH=${ROOT_PATH}/utilities/binaries:${PATH}
export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/

LSB_RELEASE=`lsb_release -si`
if [ "$LSB_RELEASE" == "Debian" ]; then
   CC=gnatgcc
else
   CC=gcc
fi

gnatmake -P ${ROOT_PATH}/utilities/utilities.gpr

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

rm -rf ${BUILDROOT}/src/BUILD/gcc-${GCC_FULL_VERSION}-native

cd ${BUILDROOT}/src
mkdir -p BUILD/gcc-${GCC_FULL_VERSION}-native
cd BUILD/gcc-${GCC_FULL_VERSION}-native

echo "please confirm if CC=${CC} is fine ?"
read

#
#                Patch
#

utilities-main ${ROOT_PATH}/configurations/${TARGET}-native/gcc-${GCC_FULL_VERSION}/src/gcc-${GCC_FULL_VERSION} ${BUILDROOT}/src/gcc-${GCC_FULL_VERSION} TRUE

#
#                 Configure
#

CC=${CC} ../../gcc-${GCC_FULL_VERSION}/configure --build=x86_64-linux-gnu --target=${TARGET} --prefix=${PREFIX} --enable-checking=release --enable-languages=c,c++,ada --disable-multilib

#
#                 Make
#

make 2>&1 | tee make.log
echo "Press enter if everything is ok for [make], to continue the build"
read

sudo su -c "make install  2>&1 | tee make-install.log"




