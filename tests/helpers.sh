#!/bin/sh

FAIL="false"

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

_set_tmux_conf_helper() {
    > ~/.tmux.conf # empty filename
    while read -r _stchelper__line; do
        printf "%s\\n" "${_stchelper__line}" >> ~/.tmux.conf
    done
}

_create_test_plugin_helper() {
    _ctphelper__path="${HOME}/.tmux/plugins/tmux_test_plugin/"
    rm -rf  "${_ctphelper__path}"
    _mkdir_p_helper "${_ctphelper__path}"

    while read -r _ctphelper__line; do
        printf "%s\\n" "${_ctphelper__line}" >> "${_ctphelper__path}/test_plugin.tmux"
    done
    chmod +x "${_ctphelper__path}/test_plugin.tmux"
}

_teardown_helper() {
    rm ~/.tmux.conf
    rm -rf ~/.tmux/
    tmux kill-server >/dev/null 2>&1
}

_fail_helper() {
    printf "%s\\n" "${1}" >&2
    FAIL="true"
}

_exit_value_helper() {
    [ -z "${1}" ] || FAIL="${1}"
    if [ "${FAIL}" = "true" ]; then
        printf "%s\\n\\n" "FAIL!"
        exit 1
    else
        printf "%s\\n\\n" "SUCCESS"
        exit 0
    fi
}

# vim: set ts=8 sw=4 tw=0 ft=sh :
