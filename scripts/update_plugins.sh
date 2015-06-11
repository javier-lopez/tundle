#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}/helpers.sh"

_update_plugin_git() {
    [ -z "${1}" ] && return 1

    _upgit__branch=":${1##*:}"

    #update only makes sense when no specific branch/revision is set
    if [ "${_upgit__branch}" = ":${1}" ]; then
        cd "${TMUX_PLUGIN_MANAGER_PATH}/$(_get_plugin_name_helper "${1}")" && \
        GIT_TERMINAL_PROMPT="0" git pull >/dev/null 2>&1 && \
        GIT_TERMINAL_PROMPT="0" git submodule update --init --recursive >/dev/null 2>&1
    fi
}

_update_plugin_web() {
    [ -z "${1}" ] && return 1
    _upweb__plugin_name="$(_get_plugin_name_helper "${1}")"

    cd "${TMUX_PLUGIN_MANAGER_PATH}/${_upweb__plugin_name}"            && \
    [ -f "${_upweb__plugin_name}" ] && rm -rf "${_upweb__plugin_name}" && \
    (wget --no-check-certificate "${1}" || curl -k -s -O "${1}" || fetch "${1}")
}

_update_plugin_local() {
    [ -z "${1}" ] && return 1
    _uplocal__plugin_name="$(_get_plugin_name_helper "${1}")"

    cd "${TMUX_PLUGIN_MANAGER_PATH}/${_uplocal__plugin_name}"              && \
    [ -f "${_uplocal__plugin_name}" ] && rm -rf "${_uplocal__plugin_name}" && \
    cp -r "${1}" .
}

_update() {
    _update__handler="${1%%:*}:"
    _update__plugin="${1#$_update__handler}" #remove branch from plugin name

    _update__plugin_name="$(_get_plugin_name_helper "${1}")"
    _print_message_helper "Updating \"${_update__plugin_name}\""

    case "${_update__handler}" in
        ''|*/*) case "${1}" in
                /*|~*|\$*) _update_plugin_local "${1}" ;;
                *)         _update_plugin_git   "${1}" ;;
                esac ;;
        gh*|github*|git@github.com*) _update_plugin_git "${_update__plugin}" ;;
        git:)       _update_plugin_git   "${_update__plugin}"    ;;
        file:)      _update_plugin_local "${_update__plugin#//}" ;;
        http:|ftp:) _update_plugin_web   "${1}" ;;
        https:) case "${1}" in
                *github.com/*) _update_plugin_git "${_update__plugin#//github.com/}";;
                *) _update_plugin_web "${1}";;
                esac ;;
        *) _set_false_helper ;;
    esac

    [ "${?}" = "0" ] && \
    _print_message_helper "  \"${_update__plugin_name}\" update success" || \
    _print_message_helper "  \"${_update__plugin_name}\" update fail"
}


_update_all() {
    for _uall__plugin in $(_get_plugins_list_helper); do
        #update only installed plugins
        if [ -d "${TMUX_PLUGIN_MANAGER_PATH}/$(_get_plugin_name_helper "${_uall__plugin}")/" ]; then
            _update "${_uall__plugin}"
        fi
    done
}

_handle_plugin_update() {
    [ -z "${1}" ] && exit 0 || { _set_default_vars_helper || return 1; }

    if [ "${1}" = "all" ]; then
        _print_message_helper "Updating all plugins!"
        _print_message_helper
        _update_all
        return 0
    elif [ -d "${TMUX_PLUGIN_MANAGER_PATH}/${1}/" ]; then
        _update "${1}"
    else
        _display_message_helper "It seems this plugin is not installed: ${1}"
        exit 0
    fi
}

_handle_plugin_update "${1}"
_reload_tmux_environment_helper
_done_message_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
