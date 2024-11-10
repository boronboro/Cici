# XmlStarlet is a tool for manipulating XML files. It is an alternative to
# XMLLint tool used previously. Both are interchangeable for the purposes of
# this project.
#
# This snippet of a makefile is optional, and should be included only when
# appropriate. This snippet redefines implicitly the `check-xml` rule, declared
# in `GNUmakefile`, to use `xmlstarlet` instead of `xmllint`.

XMLSTARLET=xmlstarlet

CHECK_XML=${XMLSTARLET} val --err --list-bad --xsd ${srcdir}conf/FrameXML/UI.xsd

FORMAT_XML=${XMLSTARLET} fo --indent-tab --encode utf-8 --dropdtd
