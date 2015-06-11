#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}"/helpers.sh

_check_binding_defined() {
    tmux list-keys | grep "${1}" >/dev/null
}

_set_tmux_conf_helper <<- HERE
setenv -g @tpm_plugins "doesnt_matter/tmux_test_plugin"
run-shell "${PWD}/tundle"
HERE

# manually creates a local tmux plugin
_create_test_plugin_helper <<- HERE
tmux bind-key R run-shell foo_command
HERE

tmux new-session -d  # test manually, helpful to debug
sleep 1

tmux new-session -d  # tmux starts detached
_check_binding_defined "R run-shell foo_command" || _fail_helper "Plugin sourcing failed"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
