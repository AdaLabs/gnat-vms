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

ROOT_PATH=${GNAT_VMS_ROOT_PATH}
BUILDROOT=${ROOT_PATH}/builds/${GCC_VERSION}/${TARGET}-canadian-binutils
PREFIX=/opt/local/${GCC_VERSION}/canadian/
UTILS=binutils-2.23.1

export PATH=${ROOT_PATH}/utilities/binaries:${PATH}
gnatmake -P ${ROOT_PATH}/utilities/utilities.gpr

export LD_LIBRARY_PATH=/opt/local/${GCC_VERSION}/${TARGET}/lib:$LD_LIBRARY_PATH
export PATH=/opt/local/${GCC_VERSION}/${TARGET}/bin:$PATH
rm -rf ${BUILDROOT}/src/BUILD/${UTILS}

mkdir -p ${BUILDROOT}/src
cd ${BUILDROOT}/src

cp ${ROOT_PATH}/tarballs/${UTILS}.tar.bz2 .
bunzip2 -d ${UTILS}.tar.bz2
tar -xf ${UTILS}.tar

mkdir -p BUILD/${UTILS}
cd BUILD/${UTILS}

which ia64-hp-openvms-gcc
echo "please confirm gcc ok"
read

utilities-main ${ROOT_PATH}/configurations/${TARGET}-canadian/${UTILS} ${BUILDROOT}/src/${UTILS} TRUE

#
#                 Configure
#

CC=ia64-hp-openvms-gcc ../../${UTILS}/configure --build=${BUILD} --host=${HOST} --prefix=${PREFIX} --target=${TARGET} \
     --disable-werror --with-sysroot=${ROOT_PATH}/sysroots/${TARGET}

#
#                 all-gcc
#
make 2>&1 | tee mk-canadian-binutils.build.log
#  above only for libiberty to be called, so that following rpl commands can be applied
rpl -i "#define pid_t int" "//AL#define pid_t int" ${BUILDROOT}/src/BUILD/${UTILS}/libiberty/config.h
rpl -i "#define ssize_t int" "//AL#define ssize_t int" ${BUILDROOT}/src/BUILD/${UTILS}/libiberty/config.h


make 2>&1 | tee mk-canadian-binutils.build.log

cd intl
for i in `ls -1 *.o`;do BASE=`echo $i | cut -d'.' -f1`;ln -s $i $BASE.obj;done
cd ..

make 2>&1 | tee -a mk-canadian-binutils.build.log

cd intl
for i in `ls -1 *.obj`;do BASE=`echo $i | cut -d'.' -f1`;ln -s $i $BASE.o;done
cd ..

make 2>&1 | tee -a mk-canadian-binutils.build.log

cd binutils
for i in `ls -1 *.o`;do BASE=`echo $i | cut -d'.' -f1`;ln -s $i $BASE.obj;done
cd ..


make 2>&1 | tee -a mk-canadian-binutils.build.log


echo "Press enter if everything is ok, to process make install [${UTILS}]"
read
sudo su -c "PATH=/opt/local/${GCC_VERSION}/x86_64-linux-gnu/bin:/opt/local/${GCC_VERSION}/${TARGET}/bin:/usr/bin:/bin make install 2>&1 | tee mk-canadian-binutils.install.log"
	

file /opt/local/${GCC_VERSION}/canadian/bin/as