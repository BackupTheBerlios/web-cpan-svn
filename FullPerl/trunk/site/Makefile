
RSYNC = rsync --progress --verbose --rsh=ssh

ALL_DEST_BASE = dest

DOCS_COMMON_DEPS = template.wml lib/MyNavData.pm lib/MyManageNews.pm

COMMON_PREPROC_FLAGS = -I $$HOME/conf/wml/Latemp/lib -I lib
WML_FLAGS += -DLATEMP_THEME=better-scm
WML_FLAGS += $(COMMON_PREPROC_FLAGS)
TTML_FLAGS += $(COMMON_PREPROC_FLAGS)

LATEMP_WML_FLAGS =$(shell latemp-config --wml-flags)

WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../../lib/ \
	--passoption=3,-w -I../lib/ -I../../lib -I../../ -DROOT~. $(LATEMP_WML_FLAGS)

all: dummy

%.show:
	@echo "$* = $($*)"

include include.mak
include rules.mak

# Add news_feeds to this target if you want to generate an RSS feed.
dummy : latemp_targets

RSS_FEED = $(MYSITE_DEST)/rss.xml

news_feeds: $(RSS_FEED)

$(RSS_FEED): gen-feeds.pl lib/MyManageNews.pm
	perl -Ilib gen-feeds.pl --rss2-out="$@"

.PHONY: 

upload: all
	cd $(ALL_DEST_BASE)/mysite && \
	$(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/Fullperl
