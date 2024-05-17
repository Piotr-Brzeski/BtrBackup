#/bin/bash
# bb-clean.sh
# BtrBackup: Remove old Btrfs snapshots
#
# Created by Piotr Brzeski on 2022-04-15
# Copyright (c) 2022 Piotr Brzeski. All rights reserved

. $(dirname "$0")/bb-config.sh

TMP_LOG="$LOG_FILE.temp"
NUMBER=0

. $(dirname "$0")/bb-utils.sh

function read_number() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    NUMBER=$1
  fi
  if (( NUMBER < "10" )); then
    bb_error "Number of snapshots must be at least 10."
    exit 1
  fi
}

touch "$TMP_LOG"

if [ "$1" = "-vm" ]; then
  SUBVOLUME_NAME=$2
  if [ "$SUBVOLUME_NAME" = "" ]; then
    bb_error "VM name not provided."
    exit 1
  fi
  lxc info "$SUBVOLUME_NAME" > /dev/null 2>&1
  bb_check $?
  read_number $3
  COUNT=`lxc info "$SUBVOLUME_NAME" | grep "^| $SUBVOLUME_NAME" | wc -l`
  while (( $COUNT > $NUMBER )); do
    echo $COUNT
    sleep 1
    SNAPSHOT=`lxc info "$SUBVOLUME_NAME" | grep "^| $SUBVOLUME_NAME" | awk '{print $2}' | sort | head -n 1`
    if [ "$SNAPSHOT" = "" ]; then
      bb_error "Empty snapshot name."
      exit 1
    fi
    bb_log "Removing snapshot - $SNAPSHOT"
    sleep 1
    lxc delete $SUBVOLUME_NAME/$SNAPSHOT 2> "$TMP_LOG"
    bb_check $?
    sleep 1
    COUNT=`lxc info "$SUBVOLUME_NAME" | grep "^| $SUBVOLUME_NAME" | wc -l`
  done
else
  SUBVOLUME_PATH="$1"
  if [ "$SUBVOLUME_PATH" = "" ]; then
    bb_error "Subvolume path not provided."
    exit 1
  fi
  read_number $2
  COUNT=`ls -d "$SUBVOLUME_PATH"-????-??-??-??-??-?? | wc -l`
  while (( $COUNT > $NUMBER )); do
    SNAPSHOT=`ls -d "$SUBVOLUME_PATH"-????-??-??-??-??-?? | sort | head -n 1`
    bb_log "Removing snapshot - $SNAPSHOT"
    btrfs subvolume delete -c "$SNAPSHOT" 2> "$TMP_LOG"
    bb_check $?
    COUNT=`ls -d "$SUBVOLUME_PATH"-????-??-??-??-??-?? | wc -l`
  done
fi

exit 0

