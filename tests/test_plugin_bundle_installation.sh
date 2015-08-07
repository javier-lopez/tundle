#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
. "${CURRENT_DIR}"/helpers.sh
_teardown_helper

_set_tmux_conf_helper <<- HERE
run-shell "${CURRENT_DIR}/../tundle"
setenv -g @bUnDlE "chilicuil/tundle-plugins/tmux-sensible"
HERE

case "${1}" in
    m*) tmux ;; #test manually, helpful to debug
    d*) expect -d "${CURRENT_DIR}"/plugin_install.exp ;;
     *) expect "${CURRENT_DIR}"/plugin_install.exp || exec "${0}" debug ;;
esac

[ -d "${HOME}/.tmux/plugins/tmux-sensible/" ] ||
    _fail_helper "${HOME}/.tmux/plugins/tmux-sensible/ doesn't exist but should"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
