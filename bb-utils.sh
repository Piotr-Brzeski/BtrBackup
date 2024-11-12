#/bin/bash
# bb-utils.sh
# BtrBackup helper functions
#
# Created by Piotr Brzeski on 2021-07-14
# Copyright (c) 2021-2024 Piotr Brzeski. All rights reserved

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

bb_execute_remotely() {
  REMOTE_CMD="$1"
  TRY_NO=0
  while [ $TRY_NO -le 10 ]; do
    sleep "${TRY_NO}m"
    ((TRY_NO++))
    ssh $REMOTE_MACHINE -p $REMOTE_PORT "$REMOTE_CMD" 2> "$TMP_LOG"
    bb_check_no_exit $?
    if [ $? -eq 0 ]; then
      bb_log "Remote command '$REMOTE_CMD' succeeded"
      return 0
    fi
    bb_log "Remote command '$REMOTE_CMD' failed during try number $TRY_NO"
  done
  return 1
}

bb_copy_to_remote() {
  LOCAL_PATH="$1"
  REMOTE_NAME="$2"
  TRY_NO=0
  while [ $TRY_NO -le 10 ]; do
    sleep "${TRY_NO}m"
    ((TRY_NO++))
    scp -P $REMOTE_PORT -r "$LOCAL_PATH" "$REMOTE_MACHINE:$REMOTE_DIR/$REMOTE_NAME" 2> "$TMP_LOG"
    bb_check_no_exit $?
    if [ $? -eq 0 ]; then
      bb_log "Copy '$LOCAL_PATH' to '$REMOTE_MACHINE:$REMOTE_DIR/$REMOTE_NAME' succeeded"
      return 0
    fi
    bb_log "Copy '$LOCAL_PATH' to '$REMOTE_MACHINE:$REMOTE_DIR/$REMOTE_NAME' failed during try number $TRY_NO"
  done
  return 1
}

