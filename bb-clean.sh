#/bin/bash
# bb-clean.sh
# BtrBackup: iRemove old Btrfs snapshots
#
# Created by Piotr Brzeski on 2022-04-15
# Copyright (c) 2022 Piotr Brzeski. All rights reserved

. $(dirname "$0")/bb-config.sh

TMP_LOG="$LOG_FILE.temp"
LAST_SNAPSHOTS_DIR="$SNAPSHOTS_DIR/last_snapshots"

. $(dirname "$0")/bb-utils.sh

SUBVOLUME_PATH="$1"
if [ "$SUBVOLUME_PATH" = "" ]; then
  bb_error "Subvolume path not provided."
  exit 1
fi
NUMBER=0
if [[ $2 =~ ^[0-9]+$ ]]; then
  NUMBER=$2
fi
if (( NUMBER < "10" )); then
  bb_error "Number of smnapshots must be at lest 10."
  exit 1
fi

# Count snapshots
COUNT=`ls -d "$SUBVOLUME_PATH"-????-??-??-??-??-?? | wc -l`
while (( $COUNT > $NUMBER )); do
  SNAPSHOT=`ls -d "$SUBVOLUME_PATH"-????-??-??-??-??-?? | sort | head -n 1`
  bb_log "Removing snapshot - $SNAPSHOT"
  btrfs subvolume delete "$SNAPSHOT" 2> "$TMP_LOG"
  bb_check $?
  sync
  COUNT=`ls -d "$SUBVOLUME_PATH"-????-??-??-??-??-?? | wc -l`
done

exit 0

