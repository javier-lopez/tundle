#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
. "${CURRENT_DIR}"/helpers.sh
_teardown_helper

_check_binding_defined() {
    tmux list-keys | grep "${1}" >/dev/null
}

_set_tmux_conf_helper <<- HERE
setenv -g @tpm_plugins "doesnt_matter/tmux_test_plugin"
run-shell "${CURRENT_DIR}/../tundle"
HERE

#manually creates a local tmux plugin
_create_test_plugin_helper <<- HERE
tmux bind-key R run-shell foo_command
HERE

tmux new-session -d  #start tmux detached
sleep 1
_check_binding_defined "R run-shell foo_command" || _fail_helper "Source plugin test failed"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
