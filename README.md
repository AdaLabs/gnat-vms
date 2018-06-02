# gnat-vms

This project is from the initiative of PIA-SOFER, who contacted AdaLabs in order to resurect the GCC GNAT Ada 83 VMS compiler, that is no more supported by AdaCore for new clients. 
While some patches has been (some times partialy) recovered from the gcc and binutil mailing lists, some patches are from AdaLabs, 
and these last ones are licensed using the same license of the underlaying FSF components, while being co-owned by AdaLabs and PIA-SOFER.

:broken_heart: However, unfortunatly, this repository is not sufficient for you to build the GCC GNAT Ada 83 VMS compiler, as VMS based system headers are needed during the build process,
 and it is unknown if these sources are open sourced or not. 

This project aims to build an ia64-hp-openvms Ada 83 compiler. The compiler is based on FSF GCC compiler, and is achieved through 3 steps (native, cross, and canadian compilers).

FSF COTS        | Version
----------------|----------
GCC             | 4.7 
----------------|----------
Binutils        | 2.23.1
----------------|----------
MPC             | 0.8.1
----------------|----------
GMP             | 4.3.2
----------------|----------
MPFR            | 2.4.2
----------------|----------

We can view this journey as finding a way to cross a river. In order get to the other side of the rver, We will craft 3 stones, and we will use these stones to reach the opposite border of the river
without falling into it.
Each stone depends on the previous ones, that is why we need the same compiler source from the very beginning.

It is your duty to review the scripts, that also ask for root passwords during install process.

## 1. Prepare the native operating system

If you are using an Ubuntu 14.04 (Trusty Tahr) or Debian 7 (Wheezy), you can proceed directly without a schroot environement.
If you are using more recents operating system. You will need to setup a schroot environement to install one of the OS above.

### 1.1 Setup a schroot environment

Kindly read the paragraph above to make sure that this is mandatory for you.

In this example, we will install a Debian 7 (Wheezy) x86_64.
In the console, install the schroot packages and create the chrooted OS
```bash
   $ sudo aptitude install debootstrap schroot
   $ debootstrap --include=gnat,sudo,nano,wget,build-essential,m4,flex,bison,lsb-release,texinfo  wheezy /opt/local/schroots/wheezy
```

Add the chrooted Wheezy OS to your configuration. In the code below, Replace **<YOUR_USERNAME>** with your username
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

## 2. build native compiler

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
   $ ./scripts/install-gcc-native.sh
```

In order to test the newly installed native compiler, let's build and run the hello world test.

```bash
   $ export PATH=/opt/local/4.7/x86_64-linux-gnu/bin:$PATH
   $ cd tests
   $ gnatmake sources/hello.adb
   $ ./hello
hello world !
```

## 3. build cross compiler

In this section, we will build the *x86_64-linux-gnu-native* to *ia64-hp-openvms* cross compiler. It is called a cross compiler because *build* and *host* are the same, but they are different from *target*, 
 as described in the table below.

Build        | Host         | Target
------------ |--------------|------
x86_64-linux | x86_64-linux | ia64-hp-openvms


## 4. build canadian compiler

In this section, we will build the *ia64-hp-openvms* to *ia64-hp-openvms* canadian compiler. It is called a canadian compiler because *host* and *target* are the same, but they are different from *build*,
 as described in the table below.

Build        | Host            | Target
------------ |-----------------|------
x86_64-linux | ia64-hp-openvms | ia64-hp-openvms


