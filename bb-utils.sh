#/bin/bash
# bb-utils.sh
# BtrBackup helper functions
#
# Created by Piotr Brzeski on 2021-07-14
# Copyright (c) 2021 Piotr Brzeski. All rights reserved

bb_log() {
  date +"%Y-%m-%d %H:%M:%S $1" >> "$LOG_FILE"
}

bb_error() {
  >&2 echo "$1"
  bb_log "ERROR: $1"
}

bb_check_no_exit() {
  if [ $1 -ne 0 ]; then
    ERROR=`cat "$TMP_LOG"`
    bb_error "$ERROR"
    rm -rf "$TMP_LOG"
    return 1
  fi
  rm -rf "$TMP_LOG"
  return 0
}

bb_check() {
  bb_check_no_exit $1
  if [ $1 -ne 0 ]; then
    exit 1
  fi
}

bb_change_pkg_state() {
  NEW_PATH=${PACKAGE_PATH%.$1}.$2
  mv "$PACKAGE_PATH" "$NEW_PATH" 2> "$TMP_LOG"
  bb_check $?
  PACKAGE_PATH="$NEW_PATH"
}

