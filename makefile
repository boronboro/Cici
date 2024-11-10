.POSIX:

.PRAGMA: posix_202x

# NAME must be in [a-z0-9] and must not contain special characters or
# delimiters. Otherwise, the game client will quietly ignore the add-on and not
# load it.
NAME=chorus
VERSION=0.10.0

srcdir=./

SHELL=/bin/sh

GIT=git
GITFLAGS=--git-dir=${srcdir}.git/

LUA=lua
LUAFLAGS=

LUACHECK=luacheck
LUACHECKFLAGS=--config ${srcdir}conf/lua-check/luacheckrc.lua

LDOC=ldoc
LDOCFLAGS=

# WARNING: XML encoding is significant, it's "UTF-8" and __not__ "UTF8".
XMLLINT=xmllint
XMLLINTFLAGS=--nonet --encode UTF-8 --schema ${srcdir}conf/FrameXML/UI.xsd

INSTALL=unzip -d ${DESTDIR}Interface/AddOns

LUAFILES=
XMLFILES=

# Load the exact list of source snippets from a separate Makefile.
# The order in which files are passed to the command line is important.
# File `src/Chorus.lua` must be loaded first by the tools.
include ${srcdir}conf/make/src.mk

# Generate XML templates for raid frames.
include ${srcdir}conf/make/ChorusRaidFrameGenerator.mk

all: ${LUAFILES} ${XMLFILES} check

dist: ${NAME}-${VERSION}.zip check

${NAME}-${VERSION}.zip: doc/html/index.html doc/html/ldoc.css
	${GIT} ${GITFLAGS} archive --format=zip \
		--prefix=${NAME}/doc/html/ \
		--add-file=doc/html/index.html \
		--add-file=doc/html/ldoc.css \
		--prefix=${NAME}/ --output=$@ HEAD

html: doc/html/index.html

# WARNING: `ldoc` will only merge files correctly when they are under the same
# parent directory. There is a way to make it work, but the configuration file
# and working directory must be carefully set-up.

doc/html/index.html: ${LUAFILES}
	test -d doc/ || mkdir doc/
	test -d doc/html/ || mkdir doc/html/
	${LDOC} ${LDOCFLAGS} --dir=doc/html/ --all \
	--config=${srcdir}conf/lua-ldoc/ldoc.lua \
	--merge -X \
	--project=${NAME} \
	--title='${NAME}-${VERSION}' \
	--date=`${GIT} ${GITFLAGS} log --format=%as -n 1` \
	${srcdir}src/

install: ${NAME}-${VERSION}.zip
	${INSTALL} $^

# Read a list of XML files, exit with failure if any is invalid.
CHECK_XML=${XMLLINT} --noout ${XMLLINTFLAGS}

# Read a single XML file and print formatted XML to standard output.
FORMAT_XML = XMLLINT_INDENT='	' ${XMLLINT} ${XMLLINTFLAGS} --format -

check-xml: ${XMLFILES}
	${CHECK_XML} $^

check-lua: ${LUAFILES}
	${LUACHECK} ${LUACHECKFLAGS} $^

check: check-lua check-xml

clean:
	rm -f doc/html/index.html
	rm -f doc/html/ldoc.css

.PHONY: clean check check-lua check-xml install
