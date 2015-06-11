#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}"/helpers.sh

_set_tmux_conf_helper <<- HERE
run-shell "${PWD}/tundle"
setenv -g @bUnDlE "tmux-plugins/tmux-example-plugin"
HERE

#tmux; exit
# opens tmux and test it with `expect`
"${CURRENT_DIR}"/expect_successful_plugin_download ||
    _fail_helper "Tmux plugin installation failed"

# check plugin dir exists after download
[ -d "${HOME}/.tmux/plugins/tmux-example-plugin/" ] ||
    _fail_helper "Plugin download failed"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
