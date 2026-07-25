SRCS:sh= find . -type f -not -name ".*" -not -path "*/.*/*" -not -name "Makefile" |xargs realpath
HOME:sh= echo "${HOME}"
.if !${HOME}
.error "HOME environment variable is not set"
.endif
PREFIX= ${HOME}
# XXX install(1) is not POSIX
INSTALL= install
INSTALL_SYMLINK_OPT= -l s

all: ${SRCS:C/^${.CURDIR}\//./}

.for src in ${SRCS}
dest=${src:C/^${.CURDIR}\//./}
${PREFIX}/${dest}: ${src}
	@mkdir -p ${.TARGET:H}
	${INSTALL} ${INSTALL_SYMLINK_OPT} ${.ALLSRC} ${.TARGET}

.PHONY: ${dest}
${dest}: ${PREFIX}/${dest}
.endfor

clean: ${SRCS}
	rm -f ${SRCS:C/^${.CURDIR}\//${PREFIX}\/./}
