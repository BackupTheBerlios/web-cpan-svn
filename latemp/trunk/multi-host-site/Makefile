
RSYNC = rsync --progress --verbose --rsh=ssh

D = dest

DOCS_COMMON_DEPS = template.wml lib/MyNavData.pm

WML_FLAGS = -DLATEMP_THEME=better-scm

LATEMP_WML_INCLUDE_PATH =$(shell latemp-config --wml-include-path)

WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../../lib/ \
	--passoption=3,-w -I$(LATEMP_WML_INCLUDE_PATH) -I../../lib/ -I../../ \
	-DROOT~. \
	--passoption=2,-I$(LATEMP_WML_INCLUDE_PATH)

all: dummy

%.show:
	@echo "$* = $($*)"

include include.mak
include rules.mak


dummy : latemp_targets

.PHONY: 

upload_beta: all
	cd $(D) && \
	$(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/__LaTemp-Beta-Site-f67bu9o/

