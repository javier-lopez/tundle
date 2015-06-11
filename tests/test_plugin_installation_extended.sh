#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}"/helpers.sh

_set_tmux_conf_helper <<- HERE
run-shell "${PWD}/tundle"
 setenv -g @bundle "tmux-plugins/tmux-example-plugin"
   setenv -g @BUNDLE "gh:tmux-plugins/tmux-online-status"
	setenv -g @plugin "github:tmux-plugins/tmux-battery"
setenv -g @PlUgIn "github:tmux-plugins/tmux-sidebar:master"

setenv -g @bundle "https://github.com/tmux-plugins/tmux-sensible:3ea5b"
setenv -g @bundle "http://ovh.net/files/sha1sum.txt"
setenv -g @bundle "git://git.openembedded.org/meta-micro"
setenv -g @bundle "ftp://ftp.microsoft.com/developr/readme.txt"
setenv -g @bundle "file://${PWD}/tests/run-tests-within-vm"
HERE

#tmux #test manually, helpful to debug

# opens tmux and test it with `expect`
"${CURRENT_DIR}"/expect_successful_plugin_download_extended ||
    _fail_helper "Tmux plugin installation fails"

# check plugin dir exists after download
[ -d "${HOME}/.tmux/plugins/tmux-example-plugin/" ] ||
    _fail_helper "Plugin tmux-plugins/tmux-example-plugin download failed"

[ -d "${HOME}/.tmux/plugins/tmux-online-status/" ] ||
    _fail_helper "Plugin gh:tmux-plugins/tmux-online-status download failed"

[ -d "${HOME}/.tmux/plugins/tmux-battery/" ] ||
    _fail_helper "Plugin github:tmux-plugins/tmux-battery download failed"

[ -d "${HOME}/.tmux/plugins/tmux-sidebar/" ] ||
    _fail_helper "Plugin github:tmux-plugins/tmux-sidebar:master download failed"

[ -d "${HOME}/.tmux/plugins/tmux-sensible/" ] ||
    _fail_helper "Plugin https://github.com/tmux-plugins/tmux-sensible:3ea5b download failed"

[ -d "${HOME}/.tmux/plugins/sha1sum.txt/" ] ||
    _fail_helper "Plugin http://ovh.net/files/sha1sum.txt download failed"

[ -d "${HOME}/.tmux/plugins/meta-micro/" ] ||
    _fail_helper "Plugin git://git.openembedded.org/meta-micro download failed"

[ -d "${HOME}/.tmux/plugins/readme.txt/" ] ||
    _fail_helper "Plugin ftp://ftp.microsoft.com/developr/readme.txt download failed"

[ -d "${HOME}/.tmux/plugins/run-tests-within-vm/" ] ||
    _fail_helper "Plugin file://${PWD}/tests/run-tests-within-vm failed"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
