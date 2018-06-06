#ifndef GCC_CONFIG_H
#define GCC_CONFIG_H
#ifdef GENERATOR_FILE
#error config.h is for the host, not build, machine.
#endif
#include "auto-host.h"
#ifdef IN_GCC
# include "ansidecl.h"
# include "config/vms/xm-vms.h"
#endif
#endif /* GCC_CONFIG_H */

#define HAVE_SYS_TYPES_H 1
#define HAVE_LIMITS_H 1
#define HAVE_STDLIB_H 1
#define HAVE_FCNTL_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TIME_H 1

