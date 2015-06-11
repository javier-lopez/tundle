#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}"/helpers.sh

_manually_install_the_plugin() {
    _mkdir_p_helper ~/.tmux/plugins/
    cd ~/.tmux/plugins/
    git clone https://github.com/tmux-plugins/tmux-example-plugin >/dev/null 2>&1
}

_set_tmux_conf_helper <<- HERE
run-shell "${PWD}/tundle"
setenv -g @tpm_plugins "tmux-plugins/tmux-example-plugin"
HERE

_manually_install_the_plugin

#tmux #test manually, helpful to debug

# opens tmux and test it with `expect`
"${CURRENT_DIR}"/expect_successful_update_of_all_plugins     || \
    _fail_helper "Tmux 'update all plugins' fails"

"${CURRENT_DIR}"/expect_successful_update_of_a_single_plugin || \
    _fail_helper "Tmux 'update single plugin' fails"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
