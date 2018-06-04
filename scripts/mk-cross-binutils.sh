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
BUILDROOT=${ROOT_PATH}/builds/${GCC_VERSION}/${TARGET}-binutils
PREFIX=/opt/local/${GCC_VERSION}/$TARGET/
UTILS=binutils-2.23.1

export LD_LIBRARY_PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/lib:$LD_LIBRARY_PATH
export PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:$PATH

rm -rf ${BUILDROOT}/src/BUILD/${UTILS}

mkdir -p ${BUILDROOT}/src
cd ${BUILDROOT}/src

cp ${ROOT_PATH}/tarballs/${UTILS}.tar.bz2 .
bunzip2 -d ${UTILS}.tar.bz2
tar -xf ${UTILS}.tar

mkdir -p BUILD/${UTILS}
cd BUILD/${UTILS}

which gcc
echo "please confirm gcc ok"
read

CC=gcc ../../${UTILS}/configure --build=x86_64-linux-gnu --prefix=${PREFIX} --target=${TARGET} \
    --disable-werror --with-sysroot=${ROOT_PATH}/sysroots/${TARGET}


make 2>&1 | tee mk-cross-binutils.build.log

echo "Press enter if everything is ok, to process make install [gcc-${GCC_VERSION}]"
read
sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/usr/bin:/bin make install 2>&1 | tee mk-cross-binutils.install.log"

#sudo mkdir -p $PREFIX/$TARGET/include
#sudo cp ${BUILDROOT}/src/${UTILS}/include/libiberty.h $PREFIX/$TARGET/include

cd $PREFIX/$TARGET
sudo mv lib lib.orig
sudo ln -s ${ROOT_PATH}/sysroots/${TARGET}/include .
sudo ln -s ${ROOT_PATH}/sysroots/${TARGET}/lib .
