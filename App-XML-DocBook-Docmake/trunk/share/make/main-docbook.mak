# Declare some paths

DOCMAKE_SGML_PATH = $(DOCBOOK_MAK_PATH)/share/sgml/docbook-shlomif
DOCMAKE_XSLT_PATH = $(DOCMAKE_SGML_PATH)/xsl-stylesheets
DOCMAKE_DSSSL_PATH = $(DOCMAKE_SGML_PATH)/dsssl-stylesheets


# Flags for the db2pdf, db2rtf, etc. DSSSL-based scripts

DB2_DSSSL_SS = $(DOCMAKE_DSSSL_PATH)/shlomif-essays.dsl

DB2_COMMON_FLAGS = -c /etc/sgml/catalog
DB2_PRINT_FLAGS = $(DB2_COMMON_FLAGS) -d '$(DB2_DSSSL_SS)\#print'
DB2_HTML_FLAGS = $(DB2_COMMON_FLAGS) -d '$(DB2_DSSSL_SS)\#html'

# Declare the main DocBook/XML source for the document.

MAIN_SOURCE = $(DOC).xml


# Declare the XSLT Stylesheet

XSLT_SS = $(DOCMAKE_XSLT_PATH)/shlomif-essays.xsl


# Declare the PDF and RTF documents.

PDF_DOC = $(DOC).pdf
RTF_DOC = $(DOC).rtf
FO_DOC = $(DOC).fo

# Declare the default HTML XSL target directory.
# If over-rided by the user - it would be left as is.

HTML_XSL_TARGET ?= $(DOC)


# Declare the default HTML DSSSL target directory.
# If over-rided by the user - it would be left as is.

HTML_DSSSL_TARGET = $(DOC)-dsssl


# Declare the default HTML XSL all-in-one-chunck target directory.
# If over-rided by the user - it would be left as is.

HTML_ONECHUNCK_TARGET ?= $(DOC)-onechunk


# A file inside the XSL target directory for dependency resolution

HTML_XSL_TARGET_FILE_IN_DIR = $(HTML_XSL_TARGET)/index.html


# Declare macros related to the CSS stylesheet for the HTML.

HTML_XSL_CSS_SOURCE ?= style.css


# A file inside the XSL target directory for dependency resolution

HTML_ONE_CHUNCK_TARGET_FILE = $(HTML_ONECHUNCK_TARGET)/index.html


# Define common Commands

XMLTO ?= xmlto


# Define upload-related macros

UPLOAD_DEPS ?= html pdf rtf
FILES_TO_UPLOAD ?= $(HTML_XSL_TARGET) $(PDF_DOC) $(RTF_DOC) $(ALL_SOURCES)  


MAKEFILE_SOURCE ?= Makefile


# A temporary location for uploading the all-in-one-documents for peer-review.

UPLOAD_ONECHUNCK_PATH = $${HOMEPAGE_SSH_PATH}

##################################################


COMMON_SOURCES = $(MAIN_SOURCE) $(MAKEFILE_SOURCE) $(MORE_XML_FILES)

DSSSL_SPECIFIC_SOURCES = $(DB2_DSSSL_SS) jadetex.cfg
DSSSL_SOURCES =  $(COMMON_SOURCES) $(DSSSL_SPECIFIC_SOURCES)

XSL_SPECIFIC_SOURCES = $(XSLT_SS)
XSL_SOURCES = $(COMMON_SOURCES) $(XSL_SPECIFIC_SOURCES)

OTHER_SOURCES = $(HTML_XSL_CSS_SOURCE) $(HTML_RAW_FILES)

ALL_SOURCES = $(COMMON_SOURCES) $(DSSSL_SPECIFIC_SOURCES) $(XSL_SPECIFIC_SOURCES) $(OTHER_SOURCES) $(MAKEFILE_SOURCE)

RSYNC = rsync --progress --verbose --rsh=ssh


HTML_OTHER_SOURCES_DEST = $(patsubst %,$(HTML_XSL_TARGET)/%,$(OTHER_SOURCES))


# Declare the source archive URL.

SRC_ARCHIVE = $(DOC)-docbook-source.zip


all: html

arc : $(SRC_ARCHIVE)
	

# Define some shorthand targets

html: html-xsl

html-dsssl: $(HTML_DSSSL_TARGET)

html-xsl: $(HTML_XSL_TARGET_FILE_IN_DIR) $(HTML_OTHER_SOURCES_DEST)

pdf: $(PDF_DOC)

rtf: $(RTF_DOC)

all_in_one_html: $(HTML_ONECHUNK_TARGET_FILE)



# Define the build targets.

# HTML.

$(HTML_XSL_TARGET_FILE_IN_DIR): $(XSL_SOURCES)
	$(XMLTO) -m $(XSLT_SS) -o $(HTML_XSL_TARGET) xhtml $<

$(HTML_OTHER_SOURCES_DEST) :: $(HTML_XSL_TARGET)/%: %
	cp -f $< $@

$(HTML_DSSSL_TARGET): $(DSSSL_SOURCES)
	db2html $(DB2_HTML_FLAGS) $(MAIN_SOURCE)

$(HTML_ONE_CHUNCK_TARGET_FILE): $(XSL_SOURCES)
	$(XMLTO) -m /usr/share/sgml/docbook/xsl-stylesheets/xhtml/onechunk.xsl -o $(HTML_XSL_TARGET)-onechunk xhtml $<


# PDF and RTF.

# $(PDF_DOC): $(DSSSL_SOURCES)
#	db2pdf $(DB2_PRINT_FLAGS) $(MAIN_SOURCE)
$(FO_DOC): $(XSL_SOURCES)
	$(XMLTO) -m $(XSLT_SS) fo $<

$(PDF_DOC): $(FO_DOC)
	fop -fo $< -pdf $@

$(RTF_DOC): $(DSSSL_SOURCES)
	db2rtf $(DB2_PRINT_FLAGS) $(MAIN_SOURCE)


# Source archive.

$(SRC_ARCHIVE) : $(ALL_SOURCES)
	zip -u $@ $(ALL_SOURCES)


# Upload targets

upload: $(UPLOAD_DEPS)
	$(RSYNC) -r $(FILES_TO_UPLOAD) $(UPLOAD_PATH)

upload_all_in_one: all_in_one_html
	$(RSYNC) -r $(HTML_ONECHUNK_TARGET) $(UPLOAD_ONECHUNCK_PATH)

%.show:
	@echo "$* = $($*)"
