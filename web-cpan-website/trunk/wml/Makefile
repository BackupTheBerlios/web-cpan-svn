
RSYNC = rsync --progress --verbose --rsh=ssh

ALL_DEST_BASE = dest

DOCS_COMMON_DEPS = template.wml

WML_FLAGS = -DLATEMP_THEME=better-scm-1

LATEMP_WML_FLAGS =$(shell latemp-config --wml-flags)

WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../lib/ \
	--passoption=3,-w $(LATEMP_WML_FLAGS) -I../ -DROOT~. \
    -I../lib/

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

upload: upload_berlios

upload_berlios: all
	(cd dest && $(RSYNC) -r * shlomif@shell.berlios.de:/home/groups/web-cpan/htdocs/)

.PHONY:

