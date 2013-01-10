
ROOT =		$(PWD)
SRC =		$(ROOT)/src
PROTO =		$(ROOT)/proto
OUTPUT =	$(ROOT)/output

PREFIX =	/opt/local

CC =		gcc
PKG_CREATE =	$(PREFIX)/sbin/pkg_create

PKG_NAME =	dmake
PKG_VERS =	1.0

all: $(OUTPUT)/$(PKG_NAME)-$(PKG_VERS).tgz

$(OUTPUT)/$(PKG_NAME)-$(PKG_VERS).tgz: install $(PROTO)/packlist
	mkdir -p `dirname $@`
	$(PKG_CREATE) -B $(SRC)/build-info -c $(SRC)/comment \
	    -d $(SRC)/description -f $(PROTO)/packlist -I $(PREFIX) \
	    -p $(PROTO)$(PREFIX) -U $@

install: \
	$(PROTO)$(PREFIX)/share/dmake/make.rules \
	$(PROTO)$(PREFIX)/bin/dmake \
	$(PROTO)$(PREFIX)/share/dmake/license/Copyright.html \
	$(PROTO)$(PREFIX)/share/dmake/license/OPENSOLARIS.LICENSE \
	$(PROTO)$(PREFIX)/share/dmake/license/SunStudio_license.txt \
	$(PROTO)$(PREFIX)/share/dmake/license/SunStudio12u1_DistributionREADME.txt \
	$(PROTO)$(PREFIX)/share/dmake/license/THIRDPARTYLICENSEREADME.txt

$(PROTO)/tools/hack_dmake: $(SRC)/hack_dmake.c
	mkdir -p `dirname $@`
	$(CC) -o $@ $<

$(PROTO)$(PREFIX)/bin/dmake: $(SRC)/dmake.in $(PROTO)/tools/hack_dmake
	mkdir -p `dirname $@`
	cp $< $@
	$(PROTO)/tools/hack_dmake $@ $(PREFIX)/share/dmake

$(PROTO)$(PREFIX)/share/dmake/make.rules: $(SRC)/make.rules
	mkdir -p `dirname $@`
	cp $< $@

$(PROTO)/packlist: install
	(cd $(PROTO)$(PREFIX) && find * -type f | sort) > $@

clean:
	rm -rf $(PROTO) $(OUTPUT)
	rm -f $(PKG_NAME)-$(PKG_VERS).tgz

$(PROTO)$(PREFIX)/share/dmake/license/Copyright.html: $(ROOT)/licenses/Copyright.html
	mkdir -p `dirname $@`
	cp $< $@

$(PROTO)$(PREFIX)/share/dmake/license/OPENSOLARIS.LICENSE: $(ROOT)/licenses/OPENSOLARIS.LICENSE
	mkdir -p `dirname $@`
	cp $< $@

$(PROTO)$(PREFIX)/share/dmake/license/SunStudio_license.txt: $(ROOT)/licenses/SunStudio_license.txt
	mkdir -p `dirname $@`
	cp $< $@

$(PROTO)$(PREFIX)/share/dmake/license/SunStudio12u1_DistributionREADME.txt: $(ROOT)/licenses/SunStudio12u1_DistributionREADME.txt
	mkdir -p `dirname $@`
	cp $< $@

$(PROTO)$(PREFIX)/share/dmake/license/THIRDPARTYLICENSEREADME.txt: $(ROOT)/licenses/THIRDPARTYLICENSEREADME.txt
	mkdir -p `dirname $@`
	cp $< $@

