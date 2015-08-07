#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
. "${CURRENT_DIR}"/helpers.sh
_teardown_helper

_set_tmux_conf_helper <<- HERE
run-shell "${CURRENT_DIR}/../tundle"
HERE

#manually creates a local tmux plugin
rm -rf   ~/.tmux/plugins/
_create_test_plugin_helper <<- HERE
tmux bind-key R run-shell foo_command
HERE

case "${1}" in
    m*) tmux ;; #test manually, helpful to debug
    d*) expect -d "${CURRENT_DIR}"/plugin_clean.exp ;;
     *) expect "${CURRENT_DIR}"/plugin_clean.exp || exec "${0}" debug ;;
esac

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
