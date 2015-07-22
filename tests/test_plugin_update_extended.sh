#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}"/helpers.sh

_set_tmux_conf_helper <<- HERE
run-shell "${PWD}/tundle"
 setenv -g @bundle "tmux-plugins/tmux-example-plugin"
   setenv -g @BUNDLE "gh:tmux-plugins/tmux-online-status"
	setenv -g @plugin "github:tmux-plugins/tmux-battery"
setenv -g @PlUgIn "github:tmux-plugins/tmux-sidebar:master"

setenv -g @bundle "https://github.com/chilicuil/tundle-plugins/tmux-sensible:master"
setenv -g @bundle "http://ovh.net/files/sha1sum.txt"
setenv -g @bundle "git://git.openembedded.org/meta-micro"
setenv -g @bundle "ftp://ftp1.us.freebsd.org/pub/FreeBSD/README.TXT"
setenv -g @bundle "file://${PWD}/tests/run-tests-within-vm"
HERE

#tmux #test manually, helpful to debug

# opens tmux and install plugins, test results with `expect`
"${CURRENT_DIR}"/expect_successful_plugin_download_extended ||
    _fail_helper "Tmux plugin installation phase in update fails"

# opens tmux and update plugins, test results with `expect`
"${CURRENT_DIR}"/expect_successful_update_of_all_plugins_extended ||
    _fail_helper "Tmux 'update all plugins' fails"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
