#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

. "${CURRENT_DIR}/helpers.sh"

_list_plugins_helper
_done_message_helper

# vim: set ts=8 sw=4 tw=0 ft=sh :
