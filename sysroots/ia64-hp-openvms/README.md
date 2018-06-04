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

