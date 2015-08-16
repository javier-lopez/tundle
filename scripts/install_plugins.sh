#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}/vars.sh"
. "${CURRENT_DIR}/helpers.sh"

_git_clone_subdirectory() {
    _gcsubdirectory__plugin_name="$(_get_plugin_name_helper "${1}")"
    cd "${TMUX_PLUGIN_MANAGER_PATH}" && \
    GIT_TERMINAL_PROMPT="0" git clone --recursive ${2} "${1%/*}" "${_gcsubdirectory__plugin_name}" && \
    cd "${_gcsubdirectory__plugin_name}" && git config core.sparsecheckout true && \
    printf "%s" "${_gcsubdirectory__plugin_name}" > .git/info/sparse-checkout   && \
    git read-tree -m -u HEAD
}

_git_clone() {
    cd "${TMUX_PLUGIN_MANAGER_PATH}" && \
    GIT_TERMINAL_PROMPT="0" git clone --recursive ${2} "${1}"
}

_git_checkout() {
    cd "${TMUX_PLUGIN_MANAGER_PATH}/$(_get_plugin_name_helper "${1}")" && \
    git checkout ${2}
}

#tries cloning in expected frecuency order:
#1. expands the plugin name to point to a github repo and checkout an specific directory
#  eg: 'chilicuil/tundle-plugins/plugin'
#2. expands the plugin name to point to a github repo and tries cloning again
#  eg: 'tmux-plugins/plugin'
#3. uses the plugin name directly - works if it's a valid git url
#  eg: 'git://git.domain.ltd/plugin'
_install_plugin_git() {
    _ipgit__branch=":${1##*:}"
    _ipgit__plugin="${1%$_ipgit__branch}" #remove branch from plugin name

    if [ "${_ipgit__branch}" != ":${1}" ]; then #if exists branch/revision
        _git_clone_subdirectory "https://git::@github.com/${_ipgit__plugin}" || \
            _git_clone_subdirectory "${_ipgit__plugin}" || \
            _git_clone "https://git::@github.com/${_ipgit__plugin}" || \
            _git_clone "git:${_ipgit__plugin}" || return 1
        _git_checkout "${_ipgit__plugin}" "${_ipgit__branch#:}"
    else
        _git_clone_subdirectory "https://git::@github.com/${_ipgit__plugin}" "--depth=1" || \
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
    if [ -z "${TMUX}" ]; then #non interactive
        TMUX_PLUGIN_MANAGER_PATH="$(cat /etc/tmux.conf ~/.tmux.conf 2>/dev/null | \
            awk '/(set|setenv|set-environment).*-g.*TMUX_PLUGIN_MANAGER_PATH/{if($1!~"^#"){gsub(/'\''/,"");gsub(/'\"'/,"");print $4}}')"
        [ -z "${TMUX_PLUGIN_MANAGER_PATH}" ] && TMUX_PLUGIN_MANAGER_PATH="${DEFAULT_TMUX_PLUGIN_MANAGER_PATH}"
        TMUX_PLUGIN_MANAGER_PATH="$(printf "%s\\n" "${TMUX_PLUGIN_MANAGER_PATH}" | \
            sed "s:\$HOME:${HOME}:g;s:~/:${HOME}/:;s:\"::g;s:\'::g;")"
        TMUX_PLUGIN_MANAGER_PATH="${TMUX_PLUGIN_MANAGER_PATH%/}"
        export TMUX_PLUGIN_MANAGER_PATH
    else #interactive (while running inside tmux)
        _set_default_vars_helper
    fi

    #ensure default tmux plugin path exists
    _mkdir_p_helper "${TMUX_PLUGIN_MANAGER_PATH}" || return 1
    [ -z "${TMUX}" ] && printf "%s\\n" "Installing bundles to ${TMUX_PLUGIN_MANAGER_PATH}"

    for _iplugins__plugin in $(_get_plugins_list_helper); do
        _iplugins__plugin_name="$(_get_plugin_name_helper "${_iplugins__plugin}")"

        if [ -d "${TMUX_PLUGIN_MANAGER_PATH}/${_iplugins__plugin_name}/" ]; then
            if [ -z "${TMUX}" ]; then
                printf "%s\\n" " [-] Already installed ${_iplugins__plugin_name}"
            else
                _print_message_helper "Already installed \"${_iplugins__plugin_name}\""
                if [ "${TMUX_VERSION}" -lt "18" ]; then
                    #tmux < 1.8 versions delay fullscreen output, so give additional notifications
                    _display_message_helper "Already installed \"${_iplugins__plugin_name}\"" "50000"
                fi
            fi
        else
            if [ -z "${TMUX}" ]; then
                printf "%s\\n" " [+] Installing ${_iplugins__plugin_name} ......................... " | \
                    awk '{ printf("%s", substr($0, 0, 40)); }'
            else
                _print_message_helper "Installing \"${_iplugins__plugin_name}\""
                if [ "${TMUX_VERSION}" -lt "18" ]; then
                    #tmux < 1.8 versions delay fullscreen output, so give additional notifications
                    _display_message_helper "Installing \"${_iplugins__plugin_name}\"" "50000"
                fi
            fi
            _iplugins__plugin_handler="${_iplugins__plugin%%:*}:"
            #remove handler prefix
            _iplugins__plugin_base="${_iplugins__plugin#$_iplugins__plugin_handler}"

            case "${_iplugins__plugin_handler}" in
                ''|*/*) case "${_iplugins__plugin}" in
                    /*|~*|\$*) _install_plugin_local "${_iplugins__plugin}" >/dev/null 2>&1 ;;
                            *) _install_plugin_git   "${_iplugins__plugin}" >/dev/null 2>&1 ;;
                        esac ;;
                gh:|github:|git@github.com:|git:) _install_plugin_git "${_iplugins__plugin_base}" >/dev/null 2>&1 ;;
                http:|ftp:) _install_plugin_web "${_iplugins__plugin}" >/dev/null 2>&1 ;;
                https:) case "${_iplugins__plugin}" in
                        *github.com/*) _install_plugin_git "${_iplugins__plugin_base#//github.com/}" >/dev/null 2>&1 ;;
                                    *) _install_plugin_web "${_iplugins__plugin}" >/dev/null 2>&1 ;;
                        esac ;;
                file:) _install_plugin_local "${_iplugins__plugin_base#//}" >/dev/null 2>&1 ;;
                *) _set_false_helper ;;
            esac

            if [ "${?}" = "0" ]; then
                [ -z "${TMUX}" ] && printf "%s\\n" " done" || \
                    _print_message_helper "  \"${_iplugins__plugin_name}\" download success"
            else
                [ -z "${TMUX}" ] && printf "%s\\n" " failed" || \
                    _print_message_helper "  \"${_iplugins__plugin_name}\" download fail"
            fi
        fi
    done
}

if _supported_tmux_version_helper >/dev/null 2>&1; then #required for non interactive installs
    [ -z "${TMUX}" ] || _reload_tmux_environment_helper #only when in interactive mode
    _install_plugins
    [ -z "${TMUX}" ] || _reload_tmux_environment_helper
    [ -z "${TMUX}" ] || _reloaded_message_helper
fi

# vim: set ts=8 sw=4 tw=0 ft=sh :
