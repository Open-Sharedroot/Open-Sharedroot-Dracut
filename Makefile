VERSION=dev

prefix = /usr
datadir = ${prefix}/share
pkglibdir = ${datadir}/dracut
sysconfdir = ${prefix}/etc
sbindir = ${prefix}/sbin
mandir = ${prefix}/share/man
BINDIR       = /usr/local/bin
OUTPUT_BUILD = ./build

.PHONY: install clean archive rpm testimage test all check

all: dist

install: dist
	mkdir -p $(pkglibdir)/modules.d
	cp -arx $(OUTPUT_BUILD)/modules.d/* $(pkglibdir)

uninstall: 
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/95osr-chroot
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/95osr-cluster
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/96osr
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/99osr-atix-legacy

clean:
	rm -f *~
	rm -f osr-dracut*.rpm ../osr-dracut*.tar.bz2
	$(RM) -r $(OUTPUT_BUILD)

archive: ../osr-dracut-module-$(VERSION).tar.bz2


# create distrebut-build
dist: 
	mkdir $(OUTPUT_BUILD)
	cp ./GPL*.txt $(OUTPUT_BUILD)
	cp ./README* $(OUTPUT_BUILD)
	cp ./Makefile $(OUTPUT_BUILD)
	mkdir $(OUTPUT_BUILD)/modules.d
	cp -Rv ./modules.d/* $(OUTPUT_BUILD)/modules.d/


# create tar-file
tar: dist
	tar -cvjf ./osr-dracut-module_`date +%F`.tar.bz2 $(OUTPUT_BUILD)
	tar -cvjf ./osr-dracut-module-dev.tar.bz2 $(OUTPUT_BUILD)


rpm: clean dist
	rpmbuild \
	--define "_topdir $$PWD" \
	--define "_sourcedir $$PWD" \
	--define "_specdir $$PWD" \
	--define "_srcrpmdir $$PWD" \
	--define "_rpmdir $$PWD" \
	-ba osr-dracut-module.spec


check: all
	@ret=0;for i in modules.d/*/*.sh; do \
		dash -n "$$i" ; ret=$$(($$ret+$$?)); \
	done;exit $$ret
	make -C test check

