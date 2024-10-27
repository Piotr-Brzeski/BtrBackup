#/bin/bash
# bb-send.sh
# BtrBackup: Send packages to the remote server using SSH
#
# Created by Piotr Brzeski on 2021-07-14
# Copyright (c) 2021-2024 Piotr Brzeski. All rights reserved

. $(dirname "$0")/bb-config.sh

TMP_LOG="$LOG_FILE.temp"

. $(dirname "$0")/bb-utils.sh

for PACKAGE_PATH in `ls -d "$PACKAGES_DIR"/*.ready 2> /dev/null | sort`; do
  PACKAGE_NAME=`basename "$PACKAGE_PATH" .ready`
  bb_log "$PACKAGE_NAME - Sending package"
  bb_change_pkg_state "ready" "sending"
  echo "$PACKAGE_PATH"
  scp -P $REMOTE_PORT -r "$PACKAGE_PATH" "$REMOTE_MACHINE:$REMOTE_DIR/$PACKAGE_NAME.sending" 2> "$TMP_LOG"
  bb_check $?
  bb_execute_remotely "mv \"$REMOTE_DIR/$PACKAGE_NAME.sending\" \"$REMOTE_DIR/$PACKAGE_NAME.ready\""
  bb_check $?
  bb_change_pkg_state "sending" "sent"
  bb_log "$PACKAGE_NAME - Package sent"
  if [ "$KEEP_PACKAGES" != "YES" ]; then
    bb_log "$PACKAGE_NAME - Delete sent package"
    rm -r "$PACKAGE_PATH" 2> "$TMP_LOG"
    bb_check $?
  fi
  bb_log "$PACKAGE_NAME - Sending finished"
done

exit 0

