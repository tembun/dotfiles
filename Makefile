SRCS:sh= find . -type f -not -name ".*" -not -path "*/.*/*" -not -name "Makefile" |xargs realpath
HOME:sh= echo "${HOME}"
.if !${HOME}
.error "HOME environment variable is not set"
.endif
PREFIX= ${HOME}

LINK_shrc= bashrc

all: ${SRCS:C/^${.CURDIR}\///}

.for src in ${SRCS}
src_handle=${src:C/^${.CURDIR}\///}
src_dest=.${src_handle}
main_target=${PREFIX}/${src_dest}
${main_target}: ${src}
	@mkdir -p ${.TARGET:H}
	ln -s ${.ALLSRC} ${.TARGET}

link_targets=
.if defined(LINK_${src_handle})
link_targets=${LINK_${src_handle}:C/^/${PREFIX}\/./}
.for link_target in ${link_targets}
${link_target}: ${src}
	@mkdir -p ${.TARGET:H}
	ln -s ${.ALLSRC} ${.TARGET}
.endfor
.endif

.PHONY: ${src_handle}
${src_handle}: ${main_target} ${link_targets}
.endfor

clean: ${SRCS}
	rm -f ${SRCS:C/^${.CURDIR}\//${PREFIX}\/./}
