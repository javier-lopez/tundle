#!/bin/sh

# when invoked with `prefix + U` this script:
# - shows a list of installed plugins
# - starts a prompt to enter the name of the plugin that will be updated

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}/helpers.sh"

_update_plugin_prompt() {
    if ! _list_plugins_helper; then
        _done_message_helper
        return 0
    fi

    _print_message_helper
    _print_message_helper "Type plugin name to update it."
    _print_message_helper
    _print_message_helper "- \"all\" - updates all plugins"
    _print_message_helper "- ENTER - cancels"

    tmux command-prompt -p 'plugin update:' " \
    send-keys C-c; \
    run-shell '${CURRENT_DIR}/update_plugins.sh %1'"
}

_reload_tmux_environment_helper
_update_plugin_prompt

# vim: set ts=8 sw=4 tw=0 ft=sh :
