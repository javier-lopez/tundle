#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
. "${CURRENT_DIR}"/helpers.sh
_teardown_helper

_set_tmux_conf_helper <<- HERE
run-shell "${CURRENT_DIR}/../tundle"
setenv -g @bundle "https://github.com/javier-lopez/tundle-plugins/tmux-sensible:master"
setenv -g @bundle "http://ovh.net/files/sha1sum.txt"
setenv -g @bundle "git://git.openembedded.org/meta-micro"
setenv -g @bundle "ftp://ftp1.us.freebsd.org/pub/FreeBSD/README.TXT"
setenv -g @bundle "file://${CURRENT_DIR}/run_tests"

 setenv -g @bundle "tmux-plugins/tmux-example-plugin"
   setenv -g @BUNDLE "gh:tmux-plugins/tmux-online-status"
	setenv -g @plugin "github:tmux-plugins/tmux-battery"
setenv -g @PlUgIn "github:tmux-plugins/tmux-sidebar:master"
HERE

expect "${CURRENT_DIR}"/plugin_install_extended.exp ||
    _fail_helper "Installation phase in the update test failed"

case "${1}" in
    m*) tmux ;; #test manually, helpful to debug
    d*) expect -d "${CURRENT_DIR}"/plugin_update_all_extended.exp ;;
     *) expect "${CURRENT_DIR}"/plugin_update_all_extended.exp || exec "${0}" debug ;;
esac

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
