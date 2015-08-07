#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
. "${CURRENT_DIR}"/helpers.sh
_teardown_helper

_set_tmux_conf_helper <<- HERE
run-shell "${CURRENT_DIR}/../tundle"

setenv -g @bundle "chilicuil/tundle-plugins/tmux-sensible:c5c7ea1"
setenv -g @bundle "http://ovh.net/files/sha1sum.txt"
setenv -g @bundle "git://git.openembedded.org/meta-micro"
setenv -g @bundle "ftp://ftp1.us.freebsd.org/pub/FreeBSD/README.TXT"
setenv -g @bundle "file://${CURRENT_DIR}/run_tests"

 setenv -g @bundle "tmux-plugins/tmux-example-plugin"
   setenv -g @BUNDLE "gh:tmux-plugins/tmux-online-status"
	setenv -g @plugin "github:tmux-plugins/tmux-battery"
setenv -g @PlUgIn "github:tmux-plugins/tmux-sidebar:master"
HERE

case "${1}" in
    m*) tmux ;; #test manually, helpful to debug
    d*) expect -d "${CURRENT_DIR}"/plugin_install_extended.exp ;;
     *) expect "${CURRENT_DIR}"/plugin_install_extended.exp || exec "${0}" debug ;;
esac

[ -d "${HOME}/.tmux/plugins/tmux-sensible/" ] ||
    _fail_helper "chilicuil/tundle-plugins/tmux-sensible:c5c7ea1 => ${HOME}/.tmux/plugins/tmux-sensible/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/sha1sum.txt/" ] ||
    _fail_helper "http://ovh.net/files/sha1sum.txt => ${HOME}/.tmux/plugins/sha1sum.txt/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/meta-micro/" ] ||
    _fail_helper "git://git.openembedded.org/meta-micro => ${HOME}/.tmux/plugins/meta-micro/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/README.TXT/" ] ||
    _fail_helper "ftp://ftp1.us.freebsd.org/pub/FreeBSD/README.TXT => ${HOME}/.tmux/plugins/README.TXT/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/run_tests/" ] ||
    _fail_helper "file://${PWD}/tests/run_tests => ${HOME}/.tmux/plugins/run_tests/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/tmux-example-plugin/" ] ||
    _fail_helper "tmux-plugins/tmux-example-plugin => ${HOME}/.tmux/plugins/tmux-example-plugin/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/tmux-online-status/" ] ||
    _fail_helper "gh:tmux-plugins/tmux-online-status => ${HOME}/.tmux/plugins/tmux-online-status/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/tmux-battery/" ] ||
    _fail_helper "github:tmux-plugins/tmux-battery => ${HOME}/.tmux/plugins/tmux-battery/ doesn't exist but should"

[ -d "${HOME}/.tmux/plugins/tmux-sidebar/" ] ||
    _fail_helper "github:tmux-plugins/tmux-sidebar:master => ${HOME}/.tmux/plugins/tmux-sidebar/ doesn't exist but should"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
