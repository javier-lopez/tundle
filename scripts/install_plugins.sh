#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}/helpers.sh"

_git_clone_subdirectory() {
    _gcsubdirectory__plugin_name="$(_get_plugin_name_helper "${1}")"
    cd "${TMUX_PLUGIN_MANAGER_PATH}" && \
    GIT_TERMINAL_PROMPT="0" git clone --recursive "${2}" "${1%/*}" "${_gcsubdirectory__plugin_name}" && \
    cd "${_gcsubdirectory__plugin_name}" && git config core.sparsecheckout true >/dev/null 2>&1      && \
    printf "%s" "${_gcsubdirectory__plugin_name}" > .git/info/sparse-checkout && \
    git read-tree -m -u HEAD >/dev/null 2>&1
}

_git_clone() {
    cd "${TMUX_PLUGIN_MANAGER_PATH}" && \
    GIT_TERMINAL_PROMPT="0" git clone --recursive ${2} "${1}" >/dev/null 2>&1
}

_git_checkout() {
    cd "${TMUX_PLUGIN_MANAGER_PATH}/$(_get_plugin_name_helper "${1}")" && \
    git checkout ${2} >/dev/null 2>&1
}

# tries cloning in expected frecuency order:
# 1. expands the plugin name to point to a github repo and checkout an specific directory
#   eg: 'chilicuil/tundle-plugins/plugin'
# 2. expands the plugin name to point to a github repo and tries cloning again
#   eg: 'tmux-plugins/plugin'
# 3. uses the plugin name directly - works if it's a valid git url
#   eg: 'git://git.domain.ltd/plugin'
_install_plugin_git() {
    _ipgit__branch=":${1##*:}"
    _ipgit__plugin="${1%$_ipgit__branch}" #remove branch from plugin name

    if [ "${_ipgit__branch}" != ":${1}" ]; then #if exists branch/revision
        _git_clone_subdirectory "${_ipgit__plugin}"             || \
        _git_clone "https://git::@github.com/${_ipgit__plugin}" || \
        _git_clone "git:${_ipgit__plugin}" || return 1
        _git_checkout "${_ipgit__plugin}" "${_ipgit__branch#:}"
    else
        _git_clone_subdirectory "${_ipgit__plugin}" "--depth=1" || \
        _git_clone "https://git::@github.com/${_ipgit__plugin}" "--depth=1" || \
        _git_clone "git:${_ipgit__plugin}" "--depth=1"
    fi
}

_install_plugin_web() {
    _ipweb__plugin_name="$(_get_plugin_name_helper "${1}")"
    cd "${TMUX_PLUGIN_MANAGER_PATH}" && mkdir "${_ipweb__plugin_name}" && \
    cd "${_ipweb__plugin_name}" && (wget --no-check-certificate "${1}" || \
    curl -k -s -O "${1}" || fetch "${1}")
}

_install_plugin_local() {
    _iplocal__plugin_name="$(_get_plugin_name_helper "${1}")"
    cd "${TMUX_PLUGIN_MANAGER_PATH}" && mkdir "${_iplocal__plugin_name}" && \
    cd "${_iplocal__plugin_name}"    && cp -r "${1}" .
}

_install_plugins() {
    _set_default_vars_helper && \
    _ensure_default_tmux_plugin_path_exists_helper || return 1

    for _iplugins__plugin in $(_get_plugins_list_helper); do
        _iplugins__plugin_name="$(_get_plugin_name_helper "${_iplugins__plugin}")"

        if [ -d "${TMUX_PLUGIN_MANAGER_PATH}/${_iplugins__plugin_name}/" ]; then
            _print_message_helper "Already installed \"${_iplugins__plugin_name}\""
        else
            _print_message_helper "Installing \"${_iplugins__plugin_name}\""
            _iplugins__plugin_handler="${_iplugins__plugin%%:*}:"
            #remove handler prefix
            _iplugins__plugin_base="${_iplugins__plugin#$_iplugins__plugin_handler}"

            case "${_iplugins__plugin_handler}" in
                ''|*/*) case "${_iplugins__plugin}" in
                    /*|~*|\$*) _install_plugin_local "${_iplugins__plugin}" ;;
                            *) _install_plugin_git   "${_iplugins__plugin}" ;;
                        esac ;;
                gh:|github:|git@github.com:|git:) _install_plugin_git "${_iplugins__plugin_base}" ;;
                http:|ftp:) _install_plugin_web "${_iplugins__plugin}" ;;
                https:) case "${_iplugins__plugin}" in
                        *github.com/*) _install_plugin_git "${_iplugins__plugin_base#//github.com/}";;
                                    *) _install_plugin_web "${_iplugins__plugin}";;
                        esac ;;
                file:) _install_plugin_local "${_iplugins__plugin_base#//}" ;;
                *) _set_false_helper ;;
            esac

            [ "${?}" = "0" ] && \
            _print_message_helper "  \"${_iplugins__plugin_name}\" download success" || \
            _print_message_helper "  \"${_iplugins__plugin_name}\" download fail"
        fi
    done
}

_reload_tmux_environment_helper
_install_plugins
_reload_tmux_environment_helper
_reloaded_message_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
