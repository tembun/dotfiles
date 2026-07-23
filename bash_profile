test -f "${HOME}/.bashrc" && . "${HOME}/.bashrc"

CHECKGITREPO="${HOME}/scripts/checkgitrepo"
CHECKGITREPO_LIST="/etc /usr/local/etc /usr/src ${HOME}/dotfiles"
CHECKGITREPO_LOCKFILE="${TMPDIR}/.checkgitrepo.lock"
if [ ! -f "${CHECKGITREPO_LOCKFILE}" ]; then
	"${CHECKGITREPO}" ${CHECKGITREPO_LIST}
	touch "${CHECKGITREPO_LOCKFILE}"
fi

# Source completions for various programs
. /usr/local/share/bash-completion/completions/git
. /usr/local/share/bash-completion/completions/gh
