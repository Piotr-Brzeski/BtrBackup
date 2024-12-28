#/bin/bash
# bb-config.sh
# BtrBackup configuration
#
# Created by Piotr Brzeski on 2021-07-14
# Copyright (c) 2021-2024 Piotr Brzeski. All rights reserved

# Location of the log file
LOG_FILE="/backup/bb.log"

# bb-send:     Keep sent packages
# bb-recreate: Keep processsed packages
KEEP_PACKAGES=YES

# bb-create:   Path to the directory where packages will be created
# bb-send:     Path to the packages to be sent
# bb-recreate: Path to the packages to be processsed
PACKAGES_DIR="/backup/packages"

# bb-create:   Path to the directory where Btrfs snapshots will be created
# bb-recreate: Path to the directory where Btrfs snapshots will be recreated
SNAPSHOTS_DIR="/backup/snapshots"

# bb-create:   Path to the directory where information about last snapshots is stored
LAST_SNAPSHOTS_DIR="$SNAPSHOTS_DIR/last_snapshots"

# bb-send:     SSH login to the remote machine 
REMOTE_MACHINE=root@127.0.0.1

# bb-send:     SSH port of the remote machine 
REMOTE_PORT=22

# bb-send:     Path of the directory on the remote machine where packages will be saved 
REMOTE_DIR=/backup/remote/packages

