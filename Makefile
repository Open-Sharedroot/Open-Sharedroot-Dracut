# `date +%F`

VERSION=dev

prefix ?= /usr
datadir ?= ${prefix}/share
pkglibdir ?= ${datadir}/dracut
sysconfdir ?= ${prefix}/etc
sbindir ?= ${prefix}/sbin
mandir ?= ${prefix}/share/man
sysconfdir ?= ${prefix}/etc
DESTDIR =
BINDIR       = /usr/local/bin
OUTPUT_BUILD = ./osr-dracut-module-${VERSION}
DEVINSTALDIR = /lib/osr


.PHONY:   AUTHORS all archive check clean devinstall devuninstall install rpm testimage test  

all: dist


# Install all dracut modules
install:
	mkdir -p $(DESTDIR)$(pkglibdir)/modules.d
	cp -arx $(OUTPUT_BUILD)/modules.d/* $(DESTDIR)$(pkglibdir)/modules.d/
	mkdir -p /etc/osr/
	cp -arx $(OUTPUT_BUILD)/osr-configs/query-map.cfg /etc/osr/
#	cp -arx $(OUTPUT_BUILD)/modules.d/* $(pkglibdir)/modules.d/
	
# remove modules 
uninstall: 
	$(RM) -r  $(DESTDIR)$(pkglibdir)/modules.d/95osr-chroot
	$(RM) -r  $(DESTDIR)$(pkglibdir)/modules.d/95osr-cluster
	$(RM) -r  $(DESTDIR)$(pkglibdir)/modules.d/96osr
	$(RM) -r  $(DESTDIR)$(pkglibdir)/modules.d/99osr-atix-legacy
	$(RM) -r  $(DESTDIR)$(pkglibdir)/99comoonics-debug
	$(RM) -r  /etc/osr/


# make a install for develop tests
devinstall: 
	mkdir -p $(DEVINSTALDIR)
	ls ./osr-dracut-module-dev/modules.d/*/lib/*.sh | xargs -I {}  cp {}  $(DEVINSTALDIR)

# uninstall develop test install
devuninstall:
	$(RM) -r $(DEVINSTALDIR)


# cleaning the build-tmp-files
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

# creake a bz2-achiv
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
	mkdir $(OUTPUT_BUILD)/osr-configs
	cp -Rv ./osr-configs/* $(OUTPUT_BUILD)/osr-configs/


# create tar-file
tar: dist
	# with build-date
	tar -cvjf ./osr-dracut-module-dev_`date +%F`.tar.bz2 $(OUTPUT_BUILD)
	tar -cvjf ./osr-dracut-module-dev.tar.bz2 $(OUTPUT_BUILD)

# create rpms
rpm: tar
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

# create a file with autors from git log.
AUTHORS:
	git shortlog  --numbered --summary -e |while read a rest; do echo $$rest;done > ./AUTHORS

