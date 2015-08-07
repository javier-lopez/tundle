#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"
. "${CURRENT_DIR}"/helpers.sh
_teardown_helper

_manually_install_the_plugin() {
    _mkdir_p_helper ~/.tmux/plugins/
    cd ~/.tmux/plugins/
    git clone --depth=1 https://github.com/tmux-plugins/tmux-example-plugin >/dev/null 2>&1
}

_set_tmux_conf_helper <<- HERE
run-shell "${CURRENT_DIR}/../tundle"
setenv -g @tpm_plugins "tmux-plugins/tmux-example-plugin"
HERE

_manually_install_the_plugin

case "${1}" in
    m*) tmux ;; #test manually, helpful to debug
    d*) expect -d "${CURRENT_DIR}"/plugin_update_single.exp ;;
     *) expect "${CURRENT_DIR}"/plugin_update_single.exp || exec "${0}" debug ;;
esac

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
