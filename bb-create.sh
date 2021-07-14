#/bin/bash
# bb-create.sh
# BtrBackup: Create package with the Btrfs snapshot of LXD VM or Btrfs subvolume
#
# Created by Piotr Brzeski on 2021-07-14
# Copyright (c) 2021 Piotr Brzeski. All rights reserved

. $(dirname "$0")/bb-config.sh

TMP_LOG="$LOG_FILE.temp"
LAST_SNAPSHOTS_DIR="$SNAPSHOTS_DIR/last_snapshots"
TIME=`date +"%Y-%m-%d-%H-%M-%S"`

. $(dirname "$0")/bb-utils.sh

if [ "$1" = "-vm" ]; then
  SUBVOLUME_NAME=$2
  if [ "$SUBVOLUME_NAME" = "" ]; then
    bb_error "VM name not provided."
    exit 1
  fi
  # Make snapshot of the VM
  SNAPSHOT_NAME="$SUBVOLUME_NAME-$TIME"
  bb_log "$SNAPSHOT_NAME - Create snapshot"
  lxc snapshot "$SUBVOLUME_NAME" "$SNAPSHOT_NAME" 2> "$TMP_LOG"
  bb_check $?
else
  SUBVOLUME_PATH="$1"
  SUBVOLUME_NAME=`basename "$SUBVOLUME_PATH"`
  if [ "$SUBVOLUME_PATH" = "" ]; then
    bb_error "Subvolume path not provided."
    exit 1
  fi
  # Make the snapshot of the Btrfs subvolume
  SNAPSHOT_NAME="$SUBVOLUME_NAME-$TIME"
  bb_log "$SNAPSHOT_NAME - Create snapshot"
  mkdir -p "$SNAPSHOTS_DIR/$SUBVOLUME_NAME" 2> "$TMP_LOG"
  bb_check $?
  btrfs subvolume snapshot -r "$SUBVOLUME_PATH" "$SNAPSHOTS_DIR/$SUBVOLUME_NAME/$SNAPSHOT_NAME" 2> "$TMP_LOG"
  bb_check $?
fi

# Prepare package
bb_log "$SNAPSHOT_NAME - Prepare package"
PACKAGE_PATH="$PACKAGES_DIR/$SNAPSHOT_NAME.inprogress"
mkdir "$PACKAGE_PATH" 2> "$TMP_LOG"
bb_check $?
echo "$SNAPSHOT_NAME" > "$PACKAGE_PATH/name" 2> "$TMP_LOG"
bb_check $?
if [ -f "$LAST_SNAPSHOTS_DIR/$SUBVOLUME_NAME" ]; then
  bb_log "$SNAPSHOT_NAME - Prepare incremental snapshot data"
  BASE_SNAPSHOT_NAME=`cat "$LAST_SNAPSHOTS_DIR/$SUBVOLUME_NAME"` 2> "$TMP_LOG"
  bb_check $?
  echo "$BASE_SNAPSHOT_NAME" > "$PACKAGE_PATH/base" 2> "$TMP_LOG"
  bb_check $?
  btrfs send -p "$SNAPSHOTS_DIR/$SUBVOLUME_NAME/$BASE_SNAPSHOT_NAME" "$SNAPSHOTS_DIR/$SUBVOLUME_NAME/$SNAPSHOT_NAME" > "$PACKAGE_PATH/data" 2> "$TMP_LOG"
  bb_check $?
else
  bb_log "$SNAPSHOT_NAME - Prepare full snapshot data"
  btrfs send "$SNAPSHOTS_DIR/$SUBVOLUME_NAME/$SNAPSHOT_NAME" > "$PACKAGE_PATH/data" 2> "$TMP_LOG"
  bb_check $?
fi
bb_change_pkg_state "inprogress" "ready"
bb_log "$SNAPSHOT_NAME - Package ready"
mkdir -p "$LAST_SNAPSHOTS_DIR" 2> "$TMP_LOG"
bb_check $?
echo "$SNAPSHOT_NAME" > "$LAST_SNAPSHOTS_DIR/$SUBVOLUME_NAME" 2> "$TMP_LOG"
bb_check $?

exit 0

