# gnat-vms

This project is the initiative of PIA-SOFER, who contacted AdaLabs in order to resurrect the GCC GNAT Ada 83 VMS compiler, which is no more supported by AdaCore, for new clients. While some patches have been (some times partially) recovered from the gcc and binutils mailing lists, some patches are from AdaLabs. These last ones are licensed using the same license as the underlaying FSF components, while being co-owned by AdaLabs and PIA-SOFER.

:broken_heart: Unfortunatly, this repository is not sufficient for you to build the GCC GNAT Ada 83 VMS compiler, as VMS based system headers are needed during the build process, and it is unknown if these sources are open sourced or not. 

This project aims to build an ia64-hp-openvms Ada 83 compiler. The compiler is based on FSF GCC compiler, and is achieved through 3 steps (native, cross, and canadian compilers).

FSF COTS        | Version
----------------|----------
GCC             | 4.7 
Binutils        | 2.23.1
MPC             | 0.8.1
GMP             | 4.3.2
MPFR            | 2.4.2

We can view this journey as finding a way to cross a river. In order get to the other side of the river, we will craft 3 stones, and we will use these stones to reach the opposite border of the river without falling into it. Each stone depends on the previous one, this is why we need the same compiler source from the very beginning.

It is your duty to review the scripts, :warning: that also asks for root passwords during install process.

## 1. Prepare the native operating system

If you are using an Ubuntu 14.04 (Trusty Tahr) or Debian 7 (Wheezy), you can proceed directly without a schroot environment. If you are using a more recent operating system, you will need to setup a schroot environment to install one of the above OS.

### 1.1 Setup a schroot environment

Kindly read the paragraph above to make sure that this is mandatory for you.

In this example, we will install a Debian 7 (Wheezy) x86_64. In the console, install the schroot packages and create the chrooted OS
```bash
   $ sudo aptitude install debootstrap schroot
   $ debootstrap --include=gnat,sudo,nano,wget,build-essential,m4,flex,bison,lsb-release,texinfo  wheezy /opt/local/schroots/wheezy
```

Add the schrooted Wheezy OS to your configuration. In the code below, Replace **<YOUR_USERNAME>** with your username
*File /etc/schroot/chroot.d/wheezy.conf*
```
[wheezy]
description=Debian 7 Wheezy for x86_64
directory=/opt/local/schroots/wheezy
root-users=<YOUR_USERNAME>
type=directory
users=<YOUR_USERNAME>
```

Enter in your schrooted Wheezy OS
```bash
   $ schroot -c wheezy
```

## 2. Download the FSF tarballs

In the script below, we will download the GCC, Binutils, MPC, GMP and MPFR tarballs.
In the code below, replace **<YOUR_PROJECT_PATH>** with your git project path
```bash
   $ export GNAT_VMS_ROOT_PATH=<YOUR_PROJECT_PATH>
   $ cd $GNAT_VMS_ROOT_PATH
   $ ./scripts/update-tarballs.sh
```


## 3. Build native compiler

In this section, we will build the first stone for our journey, the *x86_64-linux-gnu-native* native compiler. It is called a native compiler because *build*,*host* and  *target* are the same,
 as described in the table below.

Build        | Host         | Target
------------ |--------------|------
x86_64-linux | x86_64-linux | x86_64-linux


In the code below, replace **<YOUR_PROJECT_PATH>** with your git project path
The script below will ask you a few questions and verifications, without exiting in error. 
It will ask for your *root password*, so it is your duty to review it.
```bash
   $ export GNAT_VMS_ROOT_PATH=<YOUR_PROJECT_PATH>
   $ cd $GNAT_VMS_ROOT_PATH
   $ ./scripts/install-gcc-native.sh
```

In order to test the newly installed native compiler, let's build and run the "hello world" test.

```bash
   $ cd $GNAT_VMS_ROOT_PATH
   $ export PATH=/opt/local/4.7/x86_64-linux-gnu/bin:$PATH
   $ cd tests
   $ gnatmake sources/hello.adb
   $ ./hello
hello world !
```

## 4. Build cross compiler

In this section, we will build the *x86_64-linux-gnu-native* to *ia64-hp-openvms* cross compiler. It is called a cross compiler because *build* and *host* are the same, but they are different from *target*, 
 as described in the table below.

Build        | Host         | Target
------------ |--------------|------
x86_64-linux | x86_64-linux | ia64-hp-openvms

In the code below, replace **<YOUR_PROJECT_PATH>** with your git project path
```bash
   $ export GNAT_VMS_ROOT_PATH=<YOUR_PROJECT_PATH>
```

### 4.1 Build cross binutils

The script below will ask you a few questions and verifications, without exiting in error. 
It will ask for your *root password*, so it is your duty to review it.
```bash
   $ cd $GNAT_VMS_ROOT_PATH
   $ ./scripts/mk-cross-binutils.sh
```


### 4.2 Build cross gcc


#### 4.2.1 Setup sysroot

The **$GNAT_VMS_ROOT_PATH/sysroots/ia64-hp-openvms/** sysroot shall contain two sub folders, **include** and **lib**.

**sysroot include sub-folder**
```bash
$GNAT_VMS_ROOT_PATH/sysroots/ia64-hp-openvms/include/:
_g_config.h  changes      ctype-gnu.h  errno.h  gen64def.h   limits.h  perror.h   setjmp.h   stdarg.h  stdlib.h   sys       unixio.h    varargs.h
ansidecl.h   copying3     ctype.h      fcntl.h  gnumalloc.h  locale.h  pthread.h  signal.h   stddef.h  string.h   time.h    unixlib.h   vms
assert.h     ctype-dec.h  dirent.h     float.h  libgen.h     math.h    rms.h      starlet.h  stdio.h   strings.h  unistd.h  va-alpha.h  wchar.h

$GNAT_VMS_ROOT_PATH/sysroots/ia64-hp-openvms/include.adacore/sys:
file.h  param.h  stat.h  time.h  times.h  types.h  wait.h

$GNAT_VMS_ROOT_PATH/sysroots/ia64-hp-openvms/include.adacore/vms:
atrdef.h     chfdef.h   fab.h     fatdef.h  intstkdef.h  libicb.h  namdef.h   pdscdef.h  rms.h    starlet.h  xab.h        xabfhcdef.h
chfctxdef.h  descrip.h  fabdef.h  fibdef.h  iodef.h      nam.h     ossddef.h  pthread.h  ssdef.h  stsdef.h   xabdatdef.h
```

**sysroot lib sub-folder**
```bash
$GNAT_VMS_ROOT_PATH/sysroots/ia64-hp-openvms/lib/:
cma$tis_shr.exe  decc$shr.exe  imagelib.exe  ldscripts  libdecc$shr.exe  libdeccshr.a  libimagelib.a  
libots.exe  librtl.a  librtl.exe  libstarlet.a  libsys$public_vectors.a  starlet.exe  sys$public_vectors.exe

$GNAT_VMS_ROOT_PATH/sysroots/ia64-hp-openvms/lib/ldscripts:
elf64_ia64_vms.x  elf64_ia64_vms.xbn  elf64_ia64_vms.xn  elf64_ia64_vms.xr  elf64_ia64_vms.xu
```

#### 4.2.2 Build 

The script below will ask you a few questions and verifications, without exiting in error. 
It will ask for your *root password*, so it is your duty to review it.
```bash
   $ cd $GNAT_VMS_ROOT_PATH
   $ ./scripts/install-gcc-cross.sh
```

In order to test the newly installed cross compiler, let's build the "hello world" test on *x86_64-linux*, and run it on *ia64-hp-openvms*

```bash
   $ cd $GNAT_VMS_ROOT_PATH
   $ export PATH=/opt/local/4.7/ia64-hp-openvms/bin:$PATH
   $ cd tests
   $ ia64-hp-openvms-gnatmake --RTS=/opt/local/4.7/ia64-hp-openvms/lib/gcc/ia64-hp-openvms/4.7.4/ sources/hello.adb
   $ file hello.exe
hello.exe: ELF 64-bit LSB executable, IA-64, version 1 (OpenVMS), dynamically linked, not stripped
```

Great, we got an ELF IA-64 OpenVMS binary file, upload the *hello.exe* binary on your VMS station, and run it !

```bash
   $ run hello.exe
hello world !
```

#### 4.2.3 Little tweak for ia64-hp-openvms-gcc

In order for the compiler to properly detect the default runtime, we will replace the ia64-hp-openvms-gcc symbolink link by a script that internally specifiy the runtime
```bash
cd /opt/local/4.7/ia64-hp-openvms/bin
sudo rm ia64-hp-openvms-gcc
sudo touch ia64-hp-openvms-gcc
sudo chmod +x ia64-hp-openvms-gcc
sudo nano ia64-hp-openvms-gcc
```

Add the following content to the script file (/opt/local/4.7/ia64-hp-openvms/bin/ia64-hp-openvms-gcc)
```bash
#!/bin/bash
ia64-hp-openvms-gcc.exe --RTS=/opt/local/4.7/ia64-hp-openvms/lib/gcc/ia64-hp-openvms/4.7.4/ "$@"
```

#### 4.2.4 Little tweak for ia64-hp-openvms-gnatmake

In order for the compiler to properly detect the default runtime, we will replace the ia64-hp-openvms-gnatmake symbolink link by a script that internally specifiy the runtime

```bash
cd /opt/local/4.7/ia64-hp-openvms/bin
sudo rm ia64-hp-openvms-gnatmake
sudo touch ia64-hp-openvms-gnatmake
sudo chmod +x ia64-hp-openvms-gnatmake
sudo nano ia64-hp-openvms-gnatmake
```

Add the following content to the script file (/opt/local/4.7/ia64-hp-openvms/bin/ia64-hp-openvms-gnatmake)
```bash
#!/bin/bash
ia64-hp-openvms-gnatmake.exe --RTS=/opt/local/4.7/ia64-hp-openvms/lib/gcc/ia64-hp-openvms/4.7.4/ "$@"
```

## 5. Build canadian compiler

In this section, we will build the *ia64-hp-openvms* to *ia64-hp-openvms* canadian compiler. It is called a canadian compiler because *host* and *target* are the same, but they are different from *build*,
 as described in the table below.

Build        | Host            | Target
------------ |-----------------|------
x86_64-linux | ia64-hp-openvms | ia64-hp-openvms


In the code below, replace **<YOUR_PROJECT_PATH>** with your git project path
```bash
   $ export GNAT_VMS_ROOT_PATH=<YOUR_PROJECT_PATH>
```

### 5.1 Build canadian gcc

The script below will ask you a few questions and verifications, without exiting in error. 
It will ask for your *root password*, so it is your duty to review it.
```bash
   $ cd $GNAT_VMS_ROOT_PATH
   $ ./scripts/install-gcc-canadian.sh
```

If all is going fine, you will end with 
```bash
Great, please build gnattools on target
```

### 5.2 Upload the compiler to target


### 5.3 Build GNATTOOLS on target


