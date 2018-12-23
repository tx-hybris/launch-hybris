# launch-hybris Makefile
# $Id$

-include .config
name=launch-hybris
WORKINGDIR=$(shell pwd)
DIRNAME=$(shell basename `pwd`)
VERSION=$(shell basename `pwd` |sed 's,$(name)-,,')
VERSION=$(shell date +%Y%m%d)
SPECS_DIR=/usr/src/*/SPECS
SOURCES_DIR=/usr/src/*/SOURCES

ifeq ($(CONFIG_USE_DIET),y)
  DIET=diet
else
  DIET=
endif
ifeq ($(USE_EMBEDDEDBUILD),yes)
  EMBEDDED_CFLAGS=-DSMALL_BUILD
else
  EMBEDDED_CFLAGS=
endif
HOSTCC=gcc
HOSTCC=$(shell if type gcc-4.1 >/dev/null 2>&1;then echo gcc-4.1;else echo gcc;fi)
INCLUDES=-I$(WORKINGDIR)/include -I$(WORKINGDIR)
NASM=/bin/false
ifeq ($(shell arch|egrep -q 'x86_64|i686' && echo y),y)
  CPU_OPT=-march=nocona -mtune=nocona -msse2 --param=ssp-buffer-size=4
  NASM=nasm
else
  ifeq ($(shell arch|grep -q 'arm' && echo y),y)
    CPU_OPT=-march=armv6 -mfpu=vfp -mfloat-abi=hard
  else
    CPU_OPT=
  endif
endif
BASE_CFLAGS=-std=c99 -pedantic -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -DNO_PAGE_ALLOC_ERROR
OPTFLAGS=-O2 $(CPU_OPT) -fomit-frame-pointer
GCC_WARNS_NEW=-Waddress -Warray-bounds=1 -Wbool-compare -Wchar-subscripts -Wcomment -Wenum-compare -Wformat -Wimplicit -Wimplicit-int -Wimplicit-function-declaration -Wlogical-not-parentheses -Wmain -Wmaybe-uninitialized -Wmemset-transposed-args -Wmissing-braces -Wnonnull -Wnonnull-compare -Wopenmp-simd -Wparentheses -Wpointer-sign -Wreturn-type -Wsequence-point -Wsizeof-pointer-memaccess -Wstrict-aliasing -Wstrict-overflow=1 -Wswitch -Wtautological-compare -Wtrigraphs -Wuninitialized -Wunknown-pragmas -Wunused-function -Wunused-label -Wunused-value -Wunused-variable -Wvolatile-register-var
GCC_WARNS_COMPATIBLE=-Wchar-subscripts -Wcomment -Wformat -Wimplicit -Wimplicit-int -Wimplicit-function-declaration -Wmain -Wmissing-braces -Wnonnull -Wparentheses -Wpointer-sign -Wreturn-type -Wsequence-point -Wstrict-aliasing -Wswitch -Wtrigraphs -Wuninitialized -Wunknown-pragmas -Wunused-function -Wunused-label -Wunused-value -Wunused-variable -Wvolatile-register-var
GCC_WARNS=$(shell if echo 'main(){}'|gcc $(GCC_WARNS_NEW) -E - &>/dev/null; then echo " $(GCC_WARNS_NEW)"; else echo " $(GCC_WARNS_COMPATIBLE)";fi)
#EXTRACFLAGS=-Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -pipe
EXTRACFLAGS=$(GCC_WARNS) -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -pipe
#-O -fomit-frame-pointer -Wall -D_MONOLITHIC_
#-Os -Wall -D_DEBUG_
#-O2 -fomit-frame-pointer -Wall -march=pentium4
#-O2 -fstack-protector -fomit-frame-pointer -falign-functions=1 -falign-jumps=1 -falign-loops=1 -Wall -march=pentium4 -DNO_PAGE_ALLOC_ERROR
#-O2 -fomit-frame-pointer -Wall -march=nocona -mtune=nocona -DNO_PAGE_ALLOC_ERROR
#-O2 -march=nocona -mtune=nocona -msse2 -fomit-frame-pointer -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -pipe -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE=1 -D_GNU_SOURCE -DNO_PAGE_ALLOC_ERROR
#-O2 -march=nocona -mtune=nocona -msse2 -fomit-frame-pointer -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4 -pipe -I. -I.. -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE=1 -D_GNU_SOURCE -DNO_PAGE_ALLOC_ERROR
HOSTCFLAGS=$(BASE_CFLAGS) $(OPTFLAGS) $(EXTRACFLAGS) $(EMBEDDED_CFLAGS) $(INCLUDES)
HOSTLD=ld
HOSTLDFLAGS=

CFLAGS=$(HOSTCFLAGS)
ALLCFLAGS=$(CFLAGS)
LDCFLAGS=$(ALLCFLAGS) -Wl,-z,noexecstack
CC=$(DIET) $(HOSTCC)
EXTRA_CFLAGS=
FUSEFLAGS=$(shell pkg-config fuse --cflags --libs || echo ===FUSEFLAGS_pkg-config_ERROR===)
LD=$(HOSTLD)
LDFLAGS=$(HOSTLDFLAGS)
ifneq ($(DIET),)
  EXTRA_CFLAGS+=-Wl,-lcompat
else
  EXTRA_CFLAGS+=-Wl,-lrt
endif
FUSE_FLAGS=$(shell pkg-config fuse --cflags --libs)
NASM_BIN_FLAGS=-f bin
NASM_ELF_FLAGS=-f elf
#SSTRIP=./sstrip-vladov
SSTRIP=tools/sstrip
HOSTSSTRIP=tools/sstrip-host
STRIP_ARGS=-s -R .note -R .comment
STRIP=$(HOSTSSTRIP)
USE_SSTRIP=sstrip
ifeq ($(USE_SSTRIP),"sstrip")
  STRIP=$(HOSTSSTRIP)
else
  STRIP=strip $(STRIP_ARGS)
endif
RM=/bin/rm
CP=/bin/cp -PpR 
MV=/bin/mv
LN=/bin/ln
INSTALL=install

DESTDIR=/
prefix=$(DESTDIR)/opt/$(name)
prefix=$(DESTDIR)/usr
exec_prefix=$(prefix)
bindir=$(prefix)/bin
mandir=$(prefix)/share/man
sbindir=$(prefix)/sbin
sysconfdir=$(DESTDIR)/etc
sysconfigdir=$(DESTDIR)/etc/sysconfig
datadir=$(prefix)/share
includedir=$(prefix)/include
libdir=$(prefix)/lib
libexecdir=$(prefix)/libexec
localstatedir=/var
sharedstatedir=$(prefix)/com
infodir=$(prefix)/share/info

.c.o:
	@echo CC -c -o $@ $<
	$(CC) $(ALLCFLAGS) -c -o $@ $<

usage:
	@echo -e '\n\n === targets: ===\n\nall: build tools\nclean: should be called before commit\nsavets: save timestamps\nrestorets: restore timestamps (after i.e. git checkout)\n'
	@echo -e '\n === other targets: ===\n\nsstrip'
	@echo -e '\n\n === sleeping 3 seconds then doing "make all" ==='
	@sleep 3
	@echo
	@echo OPTFLAGS=$(OPTFLAGS) $(EXTRACFLAGS) $(EMBEDDED_CFLAGS) $(INCLUDES)
	@echo HOSTCFLAGS=$(HOSTCFLAGS)
	@echo CFLAGS=$(CFLAGS)
	@echo
	$(MAKE) all

.PHONY: clean all usage tools sstrip

all: sstrip tools

tools: launch-hybris-c launch-hybris-asm

sstrip: tools/sstrip.c
	@echo CC -o tools/sstrip tools/sstrip.c
	@-$(HOSTCC) $(HOSTCFLAGS) -o $(HOSTSSTRIP) tools/sstrip.c
	@-$(CC) $(LDCFLAGS) -o tools/sstrip tools/sstrip.c
	@-$(HOSTSSTRIP) tools/sstrip

sstrip-install:
	$(INSTALL) -p $(SSTRIP) $(bindir)

sstrip-clean:
	$(RM) -f $(SSTRIP) tools/sstrip.o
	$(RM) -f $(SSTRIP) tools/sstrip-host tools/sstrip.o

launch-hybris-c: $(USE_SSTRIP) launch-hybris-c.c
	@echo CC -o launch-hybris-c launch-hybris-c.c
	@$(CC) $(LDCFLAGS) -o launch-hybris-c launch-hybris-c.c
	-$(HOSTSSTRIP) launch-hybris-c
	@chmod 755 launch-hybris-c

launch-hybris-c-install: launch-hybris-c
	$(INSTALL) -p launch-hybris-c $(bindir)

launch-hybris-c-clean:
	$(RM) -f launch-hybris-c launch-hybris-c.o

launch-hybris-asm: launch-hybris-asm.asm
	$(NASM) $(NASM_BIN_FLAGS) launch-hybris-asm.asm
	@chmod 755 launch-hybris-asm

launch-hybris-asm-install: launch-hybris-asm
	$(INSTALL) -p launch-hybris-asm $(bindir)

launch-hybris-asm-clean:
	$(RM) -f launch-hybris-asm

clean:: sstrip-clean launch-hybris-c-clean launch-hybris-asm-clean
	@echo $(RM) -f *.o
 
distclean: clean
	@-rmdir include
	#$(MAKE) savets

mangz:
	for f in $(MANPAGES); \
	do \
	  gzip -9 -f <$$f >$$f.gz; \
	  touch -r $$f $$f.gz; \
	done

desc:
	@for f in $(MANPAGES);do head -3 $$f|tail -1;done|sed 's,\\,,'

dist: tgz

tgz: distclean savets devclean
	@echo
	@echo Dir: $(DIRNAME) Version: $(VERSION)
	@perl -p -i -e 's,^Version:.*,Version: $(VERSION),' $(name).spec
	cd ..; \
	  $(RM) -rf $(DIRNAME)-$(VERSION); \
	  $(CP) $(DIRNAME) $(DIRNAME)-$(VERSION); \
	  find $(DIRNAME)-$(VERSION) -name .git -exec $(RM) -rf {} \; 2>/dev/null; \
	  find $(DIRNAME)-$(VERSION) -type d -exec rmdir -p {} \; 2>/dev/null; \
	  tar cf - $(DIRNAME)-$(VERSION) | gzip -9 -f >$(DIRNAME)-$(VERSION).tar.gz

bintgz: tgz all
	@echo Dir: $(DIRNAME) Version: $(VERSION)
	cd ..; \
	  $(RM) -rf $(DIRNAME)-$(VERSION); \
	  $(CP) $(DIRNAME) $(DIRNAME)-$(VERSION); \
	  find $(DIRNAME)-$(VERSION) -name .git -exec $(RM) -rf {} \; 2>/dev/null; \
	  find $(DIRNAME)-$(VERSION) -type d -exec rmdir -p {} \; 2>/dev/null; \
	  gzip -9 -f $(DIRNAME)-$(VERSION)/*/*.1; \
	  tar cf - \
	    $(DIRNAME)-$(VERSION)/tools/table-cell-picture-with-categories \
	    $(DIRNAME)-$(VERSION)/tools/bilder-order \
	    $(DIRNAME)-$(VERSION)/tools/table-picture-cells \
	    $(DIRNAME)-$(VERSION)/tools/erzeuge-kategorien \
	    $(DIRNAME)-$(VERSION)/tools/erzeuge-kategorien-und-bilder \
	    $(DIRNAME)-$(VERSION)/*/*.1.gz \
	    | gzip -9 -f >$(DIRNAME)-$(VERSION)-bin.tar.gz

rpm: tgz
	$(CP) $(NAME).spec $(SPECS_DIR)/
	cd ..;$(CP) $(DIRNAME).tar.gz $(SOURCES_DIR)/
	cd $(SPECS_DIR); rpmbuild -ba $(NAME).spec

savets: distclean
	find . -type f -o -type d|egrep -v "\.git\/|\.git$$"|grep -v "\.timestamps"|sort|while read f;do echo $$(date +%s -r "$$f") "$$f";done >.timestamps

restorets:
	while read ts f;do touch -d@$$ts "$$f";done<.timestamps

