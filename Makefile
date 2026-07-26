SRCS:sh= find . -type f -not -name ".*" -not -path "*/.*/*" -not -name "Makefile" |xargs realpath
HOME:sh= echo "${HOME}"
.if !${HOME}
.error "HOME environment variable is not set"
.endif
PREFIX= ${HOME}
# XXX install(1) is not POSIX
INSTALL= install
INSTALL_SYMLINK_OPT= -l s

all: ${SRCS:C/^${.CURDIR}\///}

.for src in ${SRCS}
src_handle=${src:C/^${.CURDIR}\///}
src_dest=.${src_handle}
main_target=${PREFIX}/${src_dest}
${main_target}: ${src}
	@mkdir -p ${.TARGET:H}
	${INSTALL} ${INSTALL_SYMLINK_OPT} ${.ALLSRC} ${.TARGET}

link_targets=
link_name=
.if defined(LINK_${src_handle})
link_targets=${LINK_${src_handle}:C/^/${PREFIX}\/./}
.for link_target in ${link_targets}
${link_target}: ${src}
	@mkdir -p ${.TARGET:H}
	${INSTALL} ${INSTALL_SYMLINK_OPT} ${.ALLSRC} ${.TARGET}
.endfor
.endif

.PHONY: ${src_handle}
${src_handle}: ${main_target} ${link_targets}
.endfor

clean: ${SRCS}
	rm -f ${SRCS:C/^${.CURDIR}\//${PREFIX}\/./}
