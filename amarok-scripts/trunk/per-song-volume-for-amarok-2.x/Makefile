BASE = per-song-volume

PACKAGE = $(BASE).amarokscript.tar.bz2
PACKAGE_DIR = $(BASE)

# FILES = Makefile README COPYING $(BASE).pl $(BASE).spec
FILES = Makefile README COPYING  main.js script.spec
PACKAGE_FILES = $(patsubst %,$(PACKAGE_DIR)/%,$(FILES))

all: $(PACKAGE)

$(PACKAGE): $(PACKAGE_DIR) $(PACKAGE_FILES)
	tar -cjvf $@ $(PACKAGE_DIR)
	rm -fr $(PACKAGE_DIR)

$(PACKAGE_DIR): 
	mkdir $@

$(PACKAGE_FILES) :: $(PACKAGE_DIR)/%: %
	cp -f -a $< $@
