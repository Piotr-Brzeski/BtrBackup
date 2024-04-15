#/bin/bash
# bb-recreate.sh
# BtrBackup: Recreate Btrfs subvolumes from received packages
#
# Created by Piotr Brzeski on 2021-07-13
# Copyright (c) 2021-2024 Piotr Brzeski. All rights reserved

. $(dirname "$0")/bb-config.sh

TMP_LOG="$LOG_FILE.temp"

. $(dirname "$0")/bb-utils.sh

for PACKAGE_PATH in `ls -d "$PACKAGES_DIR"/*.ready 2> /dev/null | sort`; do
  PACKAGE_NAME=`basename "$PACKAGE_PATH" .ready`
  EXPECTED_NAME=`cat "$PACKAGE_PATH/name"`
  if [ "$PACKAGE_NAME" != "$EXPECTED_NAME" ]; then
    bb_error "$PACKAGE_NAME - Invalid package name, expected $EXPECTED_NAME"
    bb_change_pkg_state "ready" "invalid"
    continue
  fi
  bb_log "$PACKAGE_NAME - Recreating"
  bb_change_pkg_state "ready" "inprogress"
  btrfs receive -f "$PACKAGE_PATH/data" "$SNAPSHOTS_DIR" 2> "$TMP_LOG"
  bb_check $?
  if [ "$KEEP_PACKAGES" = "YES" ]; then
    bb_change_pkg_state "inprogress" "done"
  else
    bb_log "$PACKAGE_NAME - Delete recreated package"
    rm -r "$PACKAGE_PATH" 2> "$TMP_LOG"
    bb_check $?
  fi
  bb_log "$PACKAGE_NAME - Recreated"
done

exit 0

