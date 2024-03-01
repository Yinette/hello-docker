# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd
DESTDIR ?=
bindir ?= $(exec_prefix)/bin
exec_prefix ?= $(prefix)
prefix ?= /usr

.PHONY: all clean install
all:
clean:
install: $(DESTDIR)$(bindir)/hello-docker $(DESTDIR)/docker-bin

$(DESTDIR):
	mkdir -p $@

$(DESTDIR)/docker-bin: | $(DESTDIR)
	install -d 755 $@

$(DESTDIR)/usr: | $(DESTDIR)
	install -d 755 $@

$(DESTDIR)/usr/local $(DESTDIR)/usr/bin: | $(DESTDIR)/usr
	install -d 755 $@

$(DESTDIR)/usr/local/bin: | $(DESTDIR)/usr/local
	install -d 755 $@

$(DESTDIR)$(bindir)/hello-docker: hello-docker | $(DESTDIR)$(bindir)
	install -m 755 $< $@
