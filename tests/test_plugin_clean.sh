#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}"/helpers.sh

_manually_install_the_plugin() {
    rm -rf   ~/.tmux/plugins/
    mkdir -p ~/.tmux/plugins/
    cd ~/.tmux/plugins/
    git clone --quiet https://github.com/tmux-plugins/tmux-example-plugin
}

_set_tmux_conf_helper <<- HERE
run-shell "${PWD}/tundle"
HERE

_manually_install_the_plugin

#tmux #test manually, helpful to debug

# opens tmux and test it with `expect`
"${CURRENT_DIR}"/expect_successful_clean_plugins ||
    _fail_helper "Clean plugin failed"

_teardown_helper
_exit_value_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
