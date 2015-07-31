#!/bin/sh

_mkdir_p_helper() { #portable mkdir -p
    for _mphelper__dir; do
        _mphelper__IFS="${IFS}"
        IFS="/"
        set -- ${_mphelper__dir}
        IFS="${_mphelper__IFS}"
        (
        case "${_mphelper__dir}" in
            /*) cd /; shift ;;
        esac
        for _mphelper__subdir; do
            [ -z "${_mphelper__subdir}" ] && continue
            if [ -d "${_mphelper__subdir}" ] || mkdir "${_mphelper__subdir}"; then
                if cd "${_mphelper__subdir}"; then
                    :
                else
                    printf "%s\\n" "_mkdir_p_helper: Can't enter ${_mphelper__subdir} while creating ${_mphelper__dir}"
                    exit 1
                fi
            else
                exit 1
            fi
        done
        )
    done
}

# this is used to get "clean" integer version number. Examples:
# `tmux 1.9` => `19`
# `1.9a`     => `19`
_get_digits_from_string_helper() {
    [ -n "${1}" ] &&  printf "%s\\n" "${1}" | tr -dC '0123456789'
}

_get_tmux_option_helper() {
    [ -z "${1}" ] && return 1

    if [ "${TMUX_VERSION-16}" -ge "18" ]; then
        _gtohelper__value="$(tmux show-option -gqv "${1}")"
    else #tmux => 1.6 altough could work on even lower tmux versions
        _gtohelper__value="$(tmux show-option -g|awk "/^${1}/ {gsub(/\'/,\"\");gsub(/\"/,\"\"); print \$2; exit;}")"
    fi

    if [ -z "${_gtohelper__value}" ]; then
        [ -z "${2}" ] && return 1 || printf "%s\\n" "${2}"
    else
        printf "%s" "${_gtohelper__value}"
    fi
}

_get_tmux_environment_helper() {
    [ -z "${1}" ] && return 1

    _gtehelper__value="$(tmux show-environment -g|awk -F"=" "/^${1}=/ {print \$2}")"

    if [ -z "${_gtehelper__value}" ]; then
        [ -z "${2}" ] && return 1 || printf "%s\\n" "${2}"
    else
        printf "%s\\n" "${_gtehelper__value}"
    fi
}

_get_tmux_option_global_helper() {
    [ -z "${1}" ] && return 1
    _gtoghelper__option="$(_get_tmux_environment_helper "${1}")"
    [ -z "${_gtoghelper__option}" ] && \
        _get_tmux_option_helper "${1}" "${2}" || \
        printf "%s" "${_gtoghelper__option}"
}

_supported_tmux_version() {
    _stversion__supported="$(_get_digits_from_string_helper "${SUPPORTED_TMUX_VERSION}")"
    if [ -z "${TMUX_VERSION}" ] || [ -z "$(_get_tmux_environment_helper "TMUX_VERSION")" ]; then
        TMUX_VERSION="$(_get_digits_from_string_helper "$(tmux -V)")"
        export TMUX_VERSION #speed up consecutive calls
        tmux set-environment -g TMUX_VERSION "${TMUX_VERSION}"
    fi

    [ "${TMUX_VERSION}" -lt "${_stversion__supported}" ] && return 1 || return 0
}

# Ensures TMUX_PLUGIN_MANAGER_PATH global env variable is set.
# That's where all the plugins are downloaded.
#
# Default path is "$HOME/.tmux/plugins/" (scripts/variables.sh)
#
# Put this in `.tmux.conf` to override the default:
# `set-environment -g TMUX_PLUGIN_MANAGER_PATH "/some/other/path/"`
_set_default_vars_helper() {
    [ -z "${TMUX_PLUGIN_MANAGER_PATH}" ] || return 0

    TMUX_PLUGIN_MANAGER_PATH="$(_get_tmux_environment_helper "TMUX_PLUGIN_MANAGER_PATH")"
    if [ -z "${TMUX_PLUGIN_MANAGER_PATH}" ]; then
        tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "${DEFAULT_TMUX_PLUGIN_MANAGER_PATH%/}"
        TMUX_PLUGIN_MANAGER_PATH="$(printf "%s\\n" "${DEFAULT_TMUX_PLUGIN_MANAGER_PATH}" | \
        sed "s:\$HOME:${HOME}:g;s:~/:${HOME}/:;s:\"::g;s:\'::g;")"
    else
        TMUX_PLUGIN_MANAGER_PATH="$(printf "%s\\n" "${TMUX_PLUGIN_MANAGER_PATH}" | \
        sed "s:\$HOME:${HOME}:g;s:~/:${HOME}/:;s:\"::g;s:\'::g;")"
    fi

    TMUX_PLUGIN_MANAGER_PATH="${TMUX_PLUGIN_MANAGER_PATH%/}"

    #speed up consecutive calls
    export TMUX_PLUGIN_MANAGER_PATH
}

_ensure_default_tmux_plugin_path_exists_helper() {
    _mkdir_p_helper "${TMUX_PLUGIN_MANAGER_PATH}"
}

_get_plugins_list_helper() {
    _gplhelper__list="$(cat /etc/tmux.conf ~/.tmux.conf 2>/dev/null | \
    awk '/(set|setenv|set-environment).*-g.*@([bB][uU][nN][dD][lL][eE]|[pP][lL][uU][gG][iI][nN])/{if($1!~"^#"){gsub(/'\''/,"");gsub(/'\"'/,"");print $4}}')"
    [ -z "${_gplhelper__list}" ] && _gplhelper__list="$(_get_tmux_option_helper "@tpm_plugins")"
    [ -z "${_gplhelper__list}" ] && _gplhelper__list="$(_get_tmux_environment_helper "@tpm_plugins")"
    [ -z "${_gplhelper__list}" ] && return 1 || printf "%s\\n" "${_gplhelper__list}"
}

# Allowed plugin name formats:
# 1.  "user/plugin_name"
# 2.  "user/plugin_name:branch"
# 3.  "gh:user/plugin_name"
# 4.  "gh:user/plugin_name:branch"
# 5.  "github:user/plugin_name"
# 6.  "github:user/plugin_name:branch"
# 7.  "http://github.com/user/plugin_name"
# 8.  "https://github.com/user/plugin_name:branch"
# 9.  "git://github.com/user/plugin_name.git"
# 10. "git://github.com/user/plugin_name.git:branch"
# 11. "git://domain.tld/plugin_name"
# 12. "git://domain.tld/plugin_name:branch"
# 13. "http://domain.tld/plugin_name"
# 14. "https://domain.tld/plugin_name"
# 15. "ftp://domain.tld/plugin_name"
# 16. "file://local/path/plugin_name"
_get_plugin_name_helper() {
    [ -z "${1}" ] && return 1
    # get only the part after the last slash, e.g. "plugin_name.git:branch"
    _gpnhelper__basename="${1##*/}"
    # remove branch (if it exists) to get only "plugin_name.git"
    _gpnhelper__name="${_gpnhelper__basename%:*}"
    # remove ".git" extension (if it exists) to get only "plugin_name"
    printf "%s\\n" "${_gpnhelper__name%.git}"
}

# TMUX messaging is weird. You only get a nice clean pane if you do it with
# `run-shell` command.
_print_message_helper() {
    if [ -z "${1}" ]; then
        tmux run-shell 'printf "%s\\n" " "'
    else
        tmux run-shell "printf '%s\\n' '${1}'"
    fi
}

_reload_tmux_environment_helper() {
    tmux source-file ~/.tmux.conf >/dev/null 2>&1
}

_list_plugins_helper() {
    _set_default_vars_helper || return 1

    for _lphelper__plugin in "${TMUX_PLUGIN_MANAGER_PATH}"/*; do
        if [ -d "${_lphelper__plugin}" ]; then
            _lphelper__plugin=""
            break
        else
            _print_message_helper "No plugins found!"
            return 1
        fi
    done

    _lphelper__plugins="$(_get_plugins_list_helper)"
    _print_message_helper "Installed plugins:"
    _print_message_helper

    for _lphelper__plugin in ${_lphelper__plugins}; do
        # displaying only installed plugins
        _lphelper__plugin_name="$(_get_plugin_name_helper "${_lphelper__plugin}")"
        if [ -d "${TMUX_PLUGIN_MANAGER_PATH}/${_lphelper__plugin_name}/" ]; then
            _print_message_helper "  \"${_lphelper__plugin_name}\""
        fi
    done
}

_reloaded_message_helper() {
    _print_message_helper
    _print_message_helper "TMUX environment reloaded."
    _print_message_helper
    _print_message_helper "Done, press ENTER to continue."
}

_done_message_helper() {
    _print_message_helper
    _print_message_helper "Done, press ENTER to continue."
}

_set_false_helper() {
    return 1
}

# Ensures a message is displayed for 5 seconds in tmux prompt.
# Does not override the 'display-time' tmux option.
_display_message_helper() {
    if [ "${#}" -eq 2 ]; then
        _dmhelper__time="${2}"
    else
        _dmhelper__time="5000"
    fi

    _dmhelper__saved_time="$(_get_tmux_option_helper "display-time" "750")"
    tmux set-option -g display-time "${_dmhelper__time}" >/dev/null
    tmux display-message "${1}"

    # restores original 'display-time' value
    tmux set-option -g display-time "${_dmhelper__saved_time}" >/dev/null
}

# vim: set ts=8 sw=4 tw=0 ft=sh :
