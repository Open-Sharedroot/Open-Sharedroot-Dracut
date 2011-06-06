# `date +%F`

VERSION=dev

prefix = /usr
datadir = ${prefix}/share
pkglibdir = ${datadir}/dracut
DESTDIR = 
sysconfdir = ${prefix}/etc
sbindir = ${prefix}/sbin
mandir = ${prefix}/share/man
BINDIR       = /usr/local/bin
OUTPUT_BUILD = ./osr-dracut-module-${VERSION}

.PHONY: install clean archive rpm testimage test all check AUTHORS

all: dist

install:
	mkdir -p $(DESTDIR)$(pkglibdir)/modules.d
	cp -arx $(OUTPUT_BUILD)/modules.d/* $(DESTDIR)$(pkglibdir)/modules.d/
#	cp -arx $(OUTPUT_BUILD)/modules.d/* $(pkglibdir)/modules.d/

uninstall: 
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/95osr-chroot
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/95osr-cluster
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/96osr
	$(RM) -r  $(OUTPUT_BUILD)/modules.d/99osr-atix-legacy

clean:
	rm -f *~
	rm -f osr-dracut*.rpm 
	$(RM) -r $(OUTPUT_BUILD)
	$(RM) ./osr-dracut*.tar.bz2
	$(RM) -r ./BUILD
	$(RM) -r ./BUILDROOT
	$(RM) -r SOURCES
	$(RM) -r SPECS
	$(RM) -r SRPMS
	$(RM) -r RPMS

archive: ../osr-dracut-module-$(VERSION).tar.bz2


# create distrebut-build
dist: AUTHORS
	mkdir $(OUTPUT_BUILD)
	cp ./GPL*.txt $(OUTPUT_BUILD)
	cp ./README* $(OUTPUT_BUILD)
	cp ./Makefile $(OUTPUT_BUILD)
	cp ./AUTHORS $(OUTPUT_BUILD)
	cp ./COPYING $(OUTPUT_BUILD)
	mkdir $(OUTPUT_BUILD)/modules.d
	cp -Rv ./modules.d/* $(OUTPUT_BUILD)/modules.d/


# create tar-file
tar: dist
	# with build-date
	tar -cvjf ./osr-dracut-module-dev_`date +%F`.tar.bz2 $(OUTPUT_BUILD)
	tar -cvjf ./osr-dracut-module-dev.tar.bz2 $(OUTPUT_BUILD)


rpm: tar
	rpmbuild \
	--define "_topdir $$PWD" \
	--define "_sourcedir $$PWD" \
	--define "_specdir $$PWD" \
	--define "_srcrpmdir $$PWD" \
	--define "_rpmdir $$PWD" \
	-ba osr-dracut-module.spec
	rm -fr BUILD BUILDROOT
	
# 	rpmbuild -v \
# 	--define "_topdir $$PWD" \
# 	--define "_sourcedir $$PWD" \
# 	-ba osr-dracut-module.spec
# 	--define "_specdir $$PWD" \
# 	--define "_srcrpmdir $$PWD" \
# 	--define "_rpmdir $$PWD" \


check: all
	@ret=0;for i in modules.d/*/*.sh; do \
		dash -n "$$i" ; ret=$$(($$ret+$$?)); \
	done;exit $$ret
	make -C test check

AUTHORS:
	git shortlog  --numbered --summary -e |while read a rest; do echo $$rest;done > AUTHORS