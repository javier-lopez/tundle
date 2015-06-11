#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}" )" && pwd)"

. "${CURRENT_DIR}/helpers.sh"

_clean_plugins() {
    _set_default_vars_helper || return 1

    _cplugins__plugins="$(_get_plugins_list_helper)"

    for _cplugins__plugin_directory in "${TMUX_PLUGIN_MANAGER_PATH}"/*; do
        [ -d "${_cplugins__plugin_directory}" ] || continue
        _cplugins__plugin_name="$(_get_plugin_name_helper "${_cplugins__plugin_directory}")"
        case "${_cplugins__plugins}" in
            *"${_cplugins__plugin_name}"*) : ;;
        *)
            [ "${_cplugins__plugin_name}" = "tundle" ] && continue
            _print_message_helper "Removing \"${_cplugins__plugin_name}\""
            rm -rf "${_cplugins__plugin_directory}"
            [ -d "${_cplugins__plugin_directory}" ] &&
                _print_message_helper "  \"${_cplugins__plugin_name}\" clean fail" ||
                _print_message_helper "  \"${_cplugins__plugin_name}\" clean success"
            ;;
    esac
done
}

_reload_tmux_environment_helper
_clean_plugins
_reload_tmux_environment_helper
_reloaded_message_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
