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
ROOT_PATH=$GNAT_VMS_ROOT_PATH/
cd $ROOT_PATH/tarballs/
wget https://ftp.gnu.org/gnu/gcc/gcc-4.7.4/gcc-4.7.4.tar.bz2
#wget http://www.multiprecision.org/mpc/download/mpc-0.8.1.tar.gz
wget https://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz
wget http://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2
wget http://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.bz2
wget https://ftp.gnu.org/gnu/binutils/binutils-2.23.1.tar.bz2
