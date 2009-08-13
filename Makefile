VERSION=0.8

prefix = /usr
datadir = ${prefix}/share
pkglibdir = ${datadir}/dracut
sysconfdir = ${prefix}/etc
sbindir = ${prefix}/sbin
mandir = ${prefix}/share/man

.PHONY: install clean archive rpm testimage test all check

all:

install:
	mkdir -p $(DESTDIR)$(pkglibdir)/modules.d
	cp -arx modules.d $(DESTDIR)$(pkglibdir)

clean:
	rm -f *~
	rm -f osr-dracut-*.rpm ../osr-dracut-*.tar.bz2

archive: ../osr-dracut-module-$(VERSION).tar.bz2

dist: ../osr-dracut-module-$(VERSION).tar.bz2

../osr-dracut-module-$(VERSION).tar.bz2:
	cd ..; \
	tar -c -j --exclude="*/CVS*" --exclude="*/BUILD*" --exclude="*/noarch*" --exclude="*/modules.d/99osr-atix-legacy*" -f osr-dracut-module-$(VERSION).tar.bz2 osr-dracut-module-$(VERSION)/*

rpm: clean ../osr-dracut-module-$(VERSION).tar.bz2
	rpmbuild --define "_topdir $$PWD" --define "_sourcedir $$PWD/.." --define "_specdir $$PWD" --define "_srcrpmdir $$PWD" --define "_rpmdir $$PWD" -ba osr-dracut-module.spec 
	rm -fr BUILD BUILDROOT

check: all
	@ret=0;for i in modules.d/*/*.sh; do \
		dash -n "$$i" ; ret=$$(($$ret+$$?)); \
	done;exit $$ret
	make -C test check
