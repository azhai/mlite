V	=	20141229

PREFIX	=	/usr/local
BINDIR	=	$(PREFIX)/bin
SHAREDIR=	$(PREFIX)/share/mlite

CC	=	cc -g

all:	mlite docs

mlite:	mlite.c
	$(CC) -o mlite mlite.c

test:	mlite make-tests.sh
	sh make-tests.sh >test.m && ./mlite -f test.m

lint:	mlite.c
	gcc -Wall -pedantic -ansi -O3 -o /dev/null mlite.c

docs:	mll.ps mll-guards.ps

mll.ps:	mll.tr paper
	groff -e -p -t -Tps -P-p9i,6i mll.tr >mll.ps 2>_meta
	sed -nf mktoc.sed <_meta | ./mlite -f cols.m | \
		sed -e 's/  *	/	/' >_toc.tr
	sed -ne 's/^R;\(.*\)/\1/p' <_meta >_xref.tr
	groff -e -p -t -Tps -P-p9i,6i mll.tr >mll.ps 2>/dev/null

mll-guards.ps:	mll-guards.tr
	groff -me -Tps -e -P-p11i,8i mll-guards.tr >mll-guards.ps

install:	mlite
	-mkdir -p $(BINDIR)
	-mkdir -p $(SHAREDIR)
	cp mlite $(BINDIR) && chmod 0755 $(BINDIR)/mlite
	strip $(BINDIR)/mlite
	cp mlite.m $(SHAREDIR) && chmod 0644 $(SHAREDIR)/mlite.m

dist:	clean
	mkdir mlite-$V
	-cp * mlite-$V
	tar cf mlite-$V.tar mlite-$V && gzip -9c <mlite-$V.tar >mlite-$V.tgz
	rm -rf mlite-$V mlite-$V.tar

csums:
	csum -u <_sums >_newsums; mv -f _newsums _sums

sums:	clean
	ls | grep -v _sums | csum >_sums

arc:	clean
	tar cvfz mlite.tgz *

clean:
	rm -f mlite mll.ps mll-guards.ps *.o *.core mlite.tgz mlite-$V.tgz \
 		mlite-$V.tar _meta _toc.tr _xref.tr
