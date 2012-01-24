# ------------------------------------------------------------------
# This file is part of bzip2/libbzip2, a program and library for
# lossless, block-sorting data compression.
#
# bzip2/libbzip2 version 1.0.6 of 6 September 2010
# Copyright (C) 1996-2010 Julian Seward <jseward@bzip.org>
#
# Please read the WARNING, DISCLAIMER and PATENTS sections in the 
# README file.
#
# This program is released under the terms of the license contained
# in the file LICENSE.
# ------------------------------------------------------------------

SHELL=/bin/sh

# To assist in cross-compiling
ifeq ($(CC),)
	CC=gcc
endif

ifeq ($(AR),)
	AR=ar
endif

ifeq ($(RANLIB),)
	RANLIB=ranlib
endif

ifeq ($(ABI),)
	ABI=armeabi
endif

ifeq ($(OUTDIR),)
	OUTDIR=out-$(ABI)
endif

LDFLAGS=

BIGFILES=-D_FILE_OFFSET_BITS=64
CFLAGS=-Wall -Winline -O2 -g $(BIGFILES)

# Where you want it installed when you do 'make install'
ifeq ($(PREFIX),)
	PREFIX=/usr/local
endif


OBJS= $(OUTDIR)/blocksort.o  \
      $(OUTDIR)/huffman.o    \
      $(OUTDIR)/crctable.o   \
      $(OUTDIR)/randtable.o  \
      $(OUTDIR)/compress.o   \
      $(OUTDIR)/decompress.o \
      $(OUTDIR)/bzlib.o

all: libbz2 bzip2 bzip2recover test

bzip2: libbz2 bzip2.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2 bzip2.o -L. -lbz2

bzip2recover: bzip2recover.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2recover bzip2recover.o

libbz2: $(OUTDIR)/libbz2.a $(OUTDIR)/libbz2.so

$(OUTDIR)/libbz2.a: $(OBJS)
	$(AR) cq $(OUTDIR)/libbz2.a $(OBJS)
	@if ( test -f $(RANLIB) -o -f /usr/bin/ranlib -o \
		-f /bin/ranlib -o -f /usr/ccs/bin/ranlib ) ; then \
		echo $(RANLIB) $(OUTDIR)/libbz2.a ; \
		$(RANLIB) $(OUTDIR)/libbz2.a ; \
	fi

$(OUTDIR)/libbz2.so: $(OBJS)
	$(CC) -shared -o $(OUTDIR)/libbz2.so $(OBJS)

check: test
test: bzip2
	@cat words1
	./bzip2 -1  < sample1.ref > sample1.rb2
	./bzip2 -2  < sample2.ref > sample2.rb2
	./bzip2 -3  < sample3.ref > sample3.rb2
	./bzip2 -d  < sample1.bz2 > sample1.tst
	./bzip2 -d  < sample2.bz2 > sample2.tst
	./bzip2 -ds < sample3.bz2 > sample3.tst
	cmp sample1.bz2 sample1.rb2 
	cmp sample2.bz2 sample2.rb2
	cmp sample3.bz2 sample3.rb2
	cmp sample1.tst sample1.ref
	cmp sample2.tst sample2.ref
	cmp sample3.tst sample3.ref
	@cat words3

install: install-libbz2 bzip2 bzip2recover
	if ( test ! -d $(PREFIX)/bin ) ; then mkdir -p $(PREFIX)/bin ; fi
	if ( test ! -d $(PREFIX)/lib ) ; then mkdir -p $(PREFIX)/lib ; fi
	if ( test ! -d $(PREFIX)/man ) ; then mkdir -p $(PREFIX)/man ; fi
	if ( test ! -d $(PREFIX)/man/man1 ) ; then mkdir -p $(PREFIX)/man/man1 ; fi
	if ( test ! -d $(PREFIX)/include ) ; then mkdir -p $(PREFIX)/include ; fi
	cp -f bzip2 $(PREFIX)/bin/bzip2
	cp -f bzip2 $(PREFIX)/bin/bunzip2
	cp -f bzip2 $(PREFIX)/bin/bzcat
	cp -f bzip2recover $(PREFIX)/bin/bzip2recover
	chmod a+x $(PREFIX)/bin/bzip2
	chmod a+x $(PREFIX)/bin/bunzip2
	chmod a+x $(PREFIX)/bin/bzcat
	chmod a+x $(PREFIX)/bin/bzip2recover
	cp -f bzip2.1 $(PREFIX)/man/man1
	chmod a+r $(PREFIX)/man/man1/bzip2.1
	cp -f bzgrep $(PREFIX)/bin/bzgrep
	ln -s -f $(PREFIX)/bin/bzgrep $(PREFIX)/bin/bzegrep
	ln -s -f $(PREFIX)/bin/bzgrep $(PREFIX)/bin/bzfgrep
	chmod a+x $(PREFIX)/bin/bzgrep
	cp -f bzmore $(PREFIX)/bin/bzmore
	ln -s -f $(PREFIX)/bin/bzmore $(PREFIX)/bin/bzless
	chmod a+x $(PREFIX)/bin/bzmore
	cp -f bzdiff $(PREFIX)/bin/bzdiff
	ln -s -f $(PREFIX)/bin/bzdiff $(PREFIX)/bin/bzcmp
	chmod a+x $(PREFIX)/bin/bzdiff
	cp -f bzgrep.1 bzmore.1 bzdiff.1 $(PREFIX)/man/man1
	chmod a+r $(PREFIX)/man/man1/bzgrep.1
	chmod a+r $(PREFIX)/man/man1/bzmore.1
	chmod a+r $(PREFIX)/man/man1/bzdiff.1
	echo ".so man1/bzgrep.1" > $(PREFIX)/man/man1/bzegrep.1
	echo ".so man1/bzgrep.1" > $(PREFIX)/man/man1/bzfgrep.1
	echo ".so man1/bzmore.1" > $(PREFIX)/man/man1/bzless.1
	echo ".so man1/bzdiff.1" > $(PREFIX)/man/man1/bzcmp.1

install-libbz2: libbz2
	if ( test ! -d $(PREFIX)/lib/$(ABI) ) ; then mkdir -p $(PREFIX)/lib/$(ABI) ; fi
	if ( test ! -d $(PREFIX)/include ) ; then mkdir -p $(PREFIX)/include ; fi
	cp -f $(OUTDIR)/libbz2.a $(PREFIX)/lib/$(ABI)
	chmod a+r $(PREFIX)/lib/$(ABI)/libbz2.a
	cp -f $(OUTDIR)/libbz2.so $(PREFIX)/lib/$(ABI)
	chmod a+r $(PREFIX)/lib/$(ABI)/libbz2.so
	cp -f bzlib.h $(PREFIX)/include
	chmod a+r $(PREFIX)/include/bzlib.h

clean: 
	rm -Rf out-* \
	sample1.rb2 sample2.rb2 sample3.rb2 \
	sample1.tst sample2.tst sample3.tst

$(OUTDIR)/blocksort.o: blocksort.c
	@cat words0
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c blocksort.c -o $(OUTDIR)/blocksort.o
$(OUTDIR)/huffman.o: huffman.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c huffman.c -o $(OUTDIR)/huffman.o
$(OUTDIR)/crctable.o: crctable.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c crctable.c -o $(OUTDIR)/crctable.o
$(OUTDIR)/randtable.o: randtable.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c randtable.c -o $(OUTDIR)/randtable.o
$(OUTDIR)/compress.o: compress.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c compress.c -o $(OUTDIR)/compress.o
$(OUTDIR)/decompress.o: decompress.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c decompress.c -o $(OUTDIR)/decompress.o
$(OUTDIR)/bzlib.o: bzlib.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c bzlib.c -o $(OUTDIR)/bzlib.o
$(OUTDIR)/bzip2.o: bzip2.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c bzip2.c -o $(OUTDIR)/bzip2.o
$(OUTDIR)/bzip2recover.o: bzip2recover.c
	@if [ ! -d $(OUTDIR) ]; then mkdir -p $(OUTDIR); fi
	$(CC) $(CFLAGS) -c bzip2recover.c -o $(OUTDIR)/bzip2recover.o


distclean: clean
	rm -f manual.ps manual.html manual.pdf

DISTNAME=bzip2-1.0.6
dist: check manual
	rm -f $(DISTNAME)
	ln -s -f . $(DISTNAME)
	tar cvf $(DISTNAME).tar \
	   $(DISTNAME)/blocksort.c \
	   $(DISTNAME)/huffman.c \
	   $(DISTNAME)/crctable.c \
	   $(DISTNAME)/randtable.c \
	   $(DISTNAME)/compress.c \
	   $(DISTNAME)/decompress.c \
	   $(DISTNAME)/bzlib.c \
	   $(DISTNAME)/bzip2.c \
	   $(DISTNAME)/bzip2recover.c \
	   $(DISTNAME)/bzlib.h \
	   $(DISTNAME)/bzlib_private.h \
	   $(DISTNAME)/Makefile \
	   $(DISTNAME)/LICENSE \
	   $(DISTNAME)/bzip2.1 \
	   $(DISTNAME)/bzip2.1.preformatted \
	   $(DISTNAME)/bzip2.txt \
	   $(DISTNAME)/words0 \
	   $(DISTNAME)/words1 \
	   $(DISTNAME)/words2 \
	   $(DISTNAME)/words3 \
	   $(DISTNAME)/sample1.ref \
	   $(DISTNAME)/sample2.ref \
	   $(DISTNAME)/sample3.ref \
	   $(DISTNAME)/sample1.bz2 \
	   $(DISTNAME)/sample2.bz2 \
	   $(DISTNAME)/sample3.bz2 \
	   $(DISTNAME)/dlltest.c \
	   $(DISTNAME)/manual.html \
	   $(DISTNAME)/manual.pdf \
	   $(DISTNAME)/manual.ps \
	   $(DISTNAME)/README \
	   $(DISTNAME)/README.COMPILATION.PROBLEMS \
	   $(DISTNAME)/README.XML.STUFF \
	   $(DISTNAME)/CHANGES \
	   $(DISTNAME)/libbz2.def \
	   $(DISTNAME)/libbz2.dsp \
	   $(DISTNAME)/dlltest.dsp \
	   $(DISTNAME)/makefile.msc \
	   $(DISTNAME)/unzcrash.c \
	   $(DISTNAME)/spewG.c \
	   $(DISTNAME)/mk251.c \
	   $(DISTNAME)/bzdiff \
	   $(DISTNAME)/bzdiff.1 \
	   $(DISTNAME)/bzmore \
	   $(DISTNAME)/bzmore.1 \
	   $(DISTNAME)/bzgrep \
	   $(DISTNAME)/bzgrep.1 \
	   $(DISTNAME)/Makefile-libbz2_so \
	   $(DISTNAME)/bz-common.xsl \
	   $(DISTNAME)/bz-fo.xsl \
	   $(DISTNAME)/bz-html.xsl \
	   $(DISTNAME)/bzip.css \
	   $(DISTNAME)/entities.xml \
	   $(DISTNAME)/manual.xml \
	   $(DISTNAME)/format.pl \
	   $(DISTNAME)/xmlproc.sh
	gzip -v $(DISTNAME).tar

# For rebuilding the manual from sources on my SuSE 9.1 box

MANUAL_SRCS= 	bz-common.xsl bz-fo.xsl bz-html.xsl bzip.css \
		entities.xml manual.xml 

manual: manual.html manual.ps manual.pdf

manual.ps: $(MANUAL_SRCS)
	./xmlproc.sh -ps manual.xml

manual.pdf: $(MANUAL_SRCS)
	./xmlproc.sh -pdf manual.xml

manual.html: $(MANUAL_SRCS)
	./xmlproc.sh -html manual.xml
