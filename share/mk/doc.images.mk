# $IdPath$
# $FreeBSD: doc/share/mk/doc.images.mk,v 1.20 2002/11/02 21:45:53 blackend Exp $
#
# This include file <doc.images.mk> handles image processing.
#
# There are two types of images that must be handled:
#
#  1.  Images from the library directory, that are shared across multiple
#      documents.
#
#  2.  Images that are document specific.
#
# For library images this file ensures that they are copied in to the 
# documents directory so that they can be reference properly.
#
# For library images *and* document specific images, this file ensures
# that the images are converted from their repository format to the
# correct output format.
#

#
# Using document specific images
# ------------------------------
#
# The images that each document provides *from the repository* are listed in
# the IMAGES variable.
#
# We then need to build a list of images that must be generated from these.
# This is to handle the case where a document might include some images as
# bitmaps and some as vector images in the repository, but where, depending
# on the output format, you want all the images in one format or another.
#
# This list of generated images can then be cleaned in the clean target
# later
#
# This is the same for each format.  To use IMAGES_GEN_PNG as an example,
# the substitution means "First match, using M, all the components of
# ${IMAGES} that match the '*.eps' regexp.  Then, search/replace the .eps
# in the matching filenames with .png.  Finally, stick the results in the
# ${IMAGES_GEN_PNG} variable."  ${IMAGES_GEN_PNG} then contains the names
# of all the .eps images listed, but with a .png extension.  This is the
# list of files we need to generate if we need PNG format images.
#
# The PDF generation, when it's looking for file 'foo', will first try
# foo.pdf, and it will try foo.png.  There's no point converting PNG files
# to PDF, as they'll be used directly.  However, we can convert the EPS files
# to PDF, and hopefully get better quality.
#

_IMAGES_PNG= ${IMAGES:M*.png}
_IMAGES_EPS= ${IMAGES:M*.eps}
_IMAGES_SCR= ${IMAGES:M*.scr}
_IMAGES_TXT= ${IMAGES:M*.txt}
_IMAGES_PIC= ${IMAGES:M*.pic}
_IMAGES_DIA= ${IMAGES:M*.dia}
_IMAGES_TEX= ${IMAGES:M*.tex}

IMAGES_GEN_PNG= ${_IMAGES_EPS:S/.eps$/.png/}
IMAGES_GEN_PNG_TEX= ${_IMAGES_TEX:S/.tex$/.png/}
IMAGES_GEN_PNG+= ${IMAGES_GEN_PNG_TEX}
IMAGES_GEN_EPS= ${_IMAGES_PNG:S/.png$/.eps/}
IMAGES_GEN_PDF= ${_IMAGES_EPS:S/.eps$/.pdf/}
IMAGES_SCR_PNG= ${_IMAGES_SCR:S/.scr$/.png/}
IMAGES_SCR_EPS= ${_IMAGES_SCR:S/.scr$/.eps/}
IMAGES_SCR_PDF= ${_IMAGES_SCR:S/.scr$/.pdf/}
IMAGES_SCR_TXT= ${_IMAGES_TXT:S/.scr$/.txt/}
IMAGES_PIC_PNG= ${_IMAGES_PIC:S/.pic$/.png/}
IMAGES_PIC_EPS= ${_IMAGES_PIC:S/.pic$/.eps/}
IMAGES_PIC_PDF= ${_IMAGES_PIC:S/.pic$/.pdf/}
IMAGES_DIA_PNG= ${_IMAGES_DIA:S/.dia$/.png/}
IMAGES_DIA_EPS= ${_IMAGES_DIA:S/.dia$/.eps/}
IMAGES_DIA_PDF= ${_IMAGES_DIA:S/.dia$/.pdf/}
IMAGES_GEN_PDF+= ${IMAGES_PIC_PDF} ${IMAGES_SCR_PDF} ${IMAGES_DIA_PDF}

CLEANFILES+= ${IMAGES_GEN_PNG} ${IMAGES_GEN_EPS} ${IMAGES_GEN_PDF}
CLEANFILES+= ${_IMAGES_TEX:S/.tex$/-img.tex/} ${_IMAGES_TEX:S/.tex$/-img.dvi/}
CLEANFILES+= ${_IMAGES_TEX:S/.tex$/.eps/}
CLEANFILES+= ${IMAGES_SCR_PNG} ${IMAGES_SCR_EPS} ${IMAGES_SCR_TXT}
CLEANFILES+= ${IMAGES_DIA_PNG} ${IMAGES_DIA_EPS}
CLEANFILES+= ${IMAGES_PIC_PNG} ${IMAGES_PIC_EPS} ${_IMAGES_PIC:S/.pic$/.ps/}

IMAGES_PNG= ${_IMAGES_PNG} ${IMAGES_GEN_PNG} ${IMAGES_SCR_PNG}
IMAGES_PNG+= ${IMAGES_DIA_PNG} ${IMAGES_PIC_PNG}
IMAGES_EPS= ${_IMAGES_EPS} ${IMAGES_GEN_EPS} ${IMAGES_SCR_EPS}
IMAGES_EPS+= ${IMAGES_DIA_EPS} ${IMAGES_PIC_EPS}
IMAGES_TXT= ${_IMAGES_TXT} ${IMAGES_SCR_TXT}

.if ${.OBJDIR} != ${.CURDIR}
LOCAL_IMAGES= ${IMAGES:S|^|${.OBJDIR}/|}
CLEANFILES+= ${LOCAL_IMAGES}

.if !empty(_IMAGES_PNG)
LOCAL_IMAGES_PNG= ${_IMAGES_PNG:S|^|${.OBJDIR}/|}
.endif

.if !empty(_IMAGES_EPS)
LOCAL_IMAGES_EPS= ${_IMAGES_EPS:S|^|${.OBJDIR}/|}
.endif

.if !empty(_IMAGES_TXT)
LOCAL_IMAGES_TXT= ${_IMAGES_TXT:S|^|${.OBJDIR}/|}
.endif

.else
LOCAL_IMAGES= ${IMAGES}
LOCAL_IMAGES_PNG= ${_IMAGES_PNG}
LOCAL_IMAGES_EPS= ${_IMAGES_EPS}
LOCAL_IMAGES_TXT= ${_IMAGES_TXT}
.endif

LOCAL_IMAGES_PNG+= ${IMAGES_GEN_PNG} ${IMAGES_SCR_PNG} ${IMAGES_DIA_PNG}
LOCAL_IMAGES_PNG+= ${IMAGES_PIC_PNG}
LOCAL_IMAGES_EPS+= ${IMAGES_GEN_EPS} ${IMAGES_SCR_EPS} ${IMAGES_DIA_EPS}
LOCAL_IMAGES_EPS+= ${IMAGES_PIC_EPS}
LOCAL_IMAGES_TXT+= ${IMAGES_SCR_TXT}

# The default resolution eps2png (82) assumes a 640x480 monitor, and is too
# low for the typical monitor in use today. The resolution of 100 looks
# much better on these monitors without making the image too large for
# a 640x480 monitor.
EPS2PNG_RES?= 100

# We only need to list ${IMAGES_GEN_PDF} here.  If all the source files are
# EPS then they'll be in this variable; if any of the source files are PNG
# then we can use them directly, and don't need to list them.
IMAGES_PDF=${IMAGES_GEN_PDF}

SCR2PNG?=	${PREFIX}/bin/scr2png
SCR2PNGOPTS?=	${SCR2PNGFLAGS}
SCR2TXT?=	${PREFIX}/bin/scr2txt
SCR2TXTOPTS?=	-l ${SCR2TXTFLAGS}
SED?=		/usr/bin/sed
EPS2PNG?=	${DOC_PREFIX}/share/tools/eps2png
EPS2PNGOPTS?=	-res ${EPS2PNG_RES} ${EPS2PNGFLAGS}
PNGTOPNM?=	${PREFIX}/bin/pngtopnm
PNGTOPNMOPTS?=	${PNGTOPNMFLAGS}
PNMTOPS?=	${PREFIX}/bin/pnmtops
PNMTOPSOPTS?=	-noturn ${PNMTOPSFLAGS}
EPSTOPDF?=	${PREFIX}/bin/epstopdf
EPSTOPDFOPTS?=	${EPSTOPDFFLAGS}
PS2EPS?=	${PREFIX}/bin/ps2epsi
PIC2PS?=	${GROFF} -p -S -Wall -mtty-char -man
REALPATH?=	/bin/realpath

# Use suffix rules to convert .scr files to other formats
.SUFFIXES:	.dia .scr .pic .png .eps .txt

.scr.png:
	${SCR2PNG} ${SCR2PNGOPTS} < ${.IMPSRC} > ${.TARGET}

.scr.eps:
	${SCR2PNG} ${SCR2PNGOPTS} < ${.ALLSRC} | \
		${PNGTOPNM} ${PNGTOPNMOPTS} | \
		${PNMTOPS} ${PNMTOPSOPTS} > ${.TARGET}

# The .txt files need to have any trailing spaces trimmed from
# each line, which is why the output from ${SCR2TXT} is run
# through ${SED}
.scr.txt:
	${SCR2TXT} ${SCR2TXTOPTS} < ${.IMPSRC} | ${SED} -E -e 's/ +$$//' > ${.TARGET}

# Some versions of ghostscript (7.04) have problems with the use of
# relative path when the arguments are passed by peps; realpath will
# correct the problem.
.pic.png: ${.TARGET:S/.png$/.eps/}
	${EPS2PNG} ${EPS2PNGOPTS} -o ${.TARGET} \
	`${REALPATH} ${.TARGET:S/.png$/.eps/}`
.pic.eps:
	${PIC2PS} ${.ALLSRC} > ${.TARGET:S/.eps$/.ps/}
	${PS2EPS} ${.OBJDIR}/${.TARGET:S/.eps$/.ps/} ${.OBJDIR}/${.TARGET}

.dia.png: ${.TARGET:S/.png$/.eps/}
	${EPS2PNG} ${EPS2PNGOPTS} -o ${.TARGET} ${.TARGET:S/.png$/.eps/}
.dia.eps:
	dia --nosplash --export=${.TARGET} ${.IMPSRC}

# We can't use suffix rules to generate the rules to convert EPS to PNG and
# PNG to EPS.  This is because a .png file can depend on a .eps file, and
# vice versa, leading to a loop in the dependency graph.  Instead, build
# the targets on the fly.

.for _curimage in ${IMAGES_GEN_PNG}
${_curimage}: ${_curimage:S/.png$/.eps/}
	${EPS2PNG} ${EPS2PNGOPTS} -o ${.TARGET} `${REALPATH} ${.ALLSRC}`
.endfor

.for _curimage in ${IMAGES_GEN_PNG_TEX}
${_curimage:S/.png$/-img.tex/}: ${_curimage:S/.png$/.tex/}
	echo \\documentclass[12pt]{article} >${.TARGET}
	echo \\begin{document} >>${.TARGET}
	echo \\pagestyle{empty} >>${.TARGET}
	cat ${.ALLSRC} >>${.TARGET}
	echo \\end{document} >>${.TARGET}

${_curimage:S/.png$/-img.dvi/}: ${_curimage:S/.png$/-img.tex/}
	latex ${.ALLSRC}
	mv *-img.dvi ${.TARGET}

${_curimage:S/.png$/.eps/}: ${_curimage:S/.png$/-img.dvi/}
	dvips -q -E -o ${.TARGET} ${.ALLSRC}
.endfor

.for _curimage in ${IMAGES_GEN_EPS}
${_curimage}: ${_curimage:S/.eps$/.png/}
	${PNGTOPNM} ${PNGTOPNMOPTS} ${.ALLSRC} | \
		${PNMTOPS} ${PNMTOPSOPTS} > ${.TARGET}
.endfor

.for _curimage in ${IMAGES_GEN_PDF}
${_curimage}: ${_curimage:S/.pdf$/.eps/}
	${EPSTOPDF} ${EPSTOPDFOPTS} --outfile=${.TARGET} ${.ALLSRC}
.endfor

.if ${.OBJDIR} != ${.CURDIR}
.for _curimage in ${IMAGES}
${.OBJDIR}/${_curimage}: ${_curimage}
	${CP} -p ${.ALLSRC} ${.TARGET}
.endfor
.endif

#
# Using library images
# --------------------
#
# Each document that wants to use one or more library images has to
# list them in the IMAGES_LIB variable.  For example, a document that wants 
# to use callouts 1 thru 4 has to list
#
#  IMAGES_LIB= callouts/1.png callouts/2.png callouts/3.png callouts/4.png
#
# in the controlling Makefile.
#
# This code ensures they exist in the current directory, and copies them in
# as necessary.
#

IMAGES_LIB?=
LOCAL_IMAGES_LIB ?=

#
# The name of the directory that contains all the library images for this
# language and encoding
#
IMAGES_LIB_DIR?=	${.CURDIR}/../../share/images

#
# The name of the directory *in* the document directory where files and
# directory hierarchies should be copied to.  "images" is too generic, and
# might clash with local document images, so use "imagelib" by default 
# instead.  If you redefine this then you must also update the
# %callout-graphics-path% variable in the .dsl file.
#
LOCAL_IMAGES_LIB_DIR?= imagelib

#
# Create a target for each image used from the library.  This target just
# ensures that each image required is copied from its location in 
# ${IMAGES_LIB_DIR} to the same place in ${LOCAL_IMAGES_LIB_DIR}.
#

.for _curimage in ${IMAGES_LIB}
LOCAL_IMAGES_LIB += ${LOCAL_IMAGES_LIB_DIR}/${_curimage}
${LOCAL_IMAGES_LIB_DIR}/${_curimage}: ${IMAGES_LIB_DIR}/${_curimage}
	@[ -d ${LOCAL_IMAGES_LIB_DIR}/${_curimage:H} ] || \
		${MKDIR} ${LOCAL_IMAGES_LIB_DIR}/${_curimage:H}
	${CP} -p ${IMAGES_LIB_DIR}/${_curimage} \
		 ${LOCAL_IMAGES_LIB_DIR}/${_curimage}
.endfor

.if !empty(IMAGES_LIB)
CLEANFILES+= ${IMAGES_LIB:S|^|${LOCAL_IMAGES_LIB_DIR}/|}
.endif
