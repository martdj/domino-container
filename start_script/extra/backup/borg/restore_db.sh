#!/bin/bash
# BorgBackup NSF Backup Script

#LOGIFILE=/local/log/restore_db.log

if [ "$LOGFILE" = "" ]; then
  OUTFILE=/dev/null
else
  OUTFILE=$LOGIFILE
fi

logfile()
{
  if [ "$LOGIFILE" = "" ]; then return 0; fi
  echo "$@" >> $LOGIFILE
}

logfile "--- RESTORE DB ---"
logfile "PhysicalFileName : $1"
logfile "FileName         : $2"
logfile "BackupReference  : $3"
logfile "BackupNode       : $4"
logfile "BackupName       : $5"
logfile "BackupMode       : $6"
logfile "BackupDateTime   : $7"
logfile "BackupTargetDir  : $8"
logfile "RestoreFileName  : $9"

TARGET="$9"

BORG_REPOSITORY="$8"
BORG_ARCHIV=$4#$6#$7$(echo "$SOURCE" | tr "/" "#" | tr " " "_")

BORG_RESTORE_MOUNT=/local/restore
BORG_LOCATION="$BORG_REPOSITORY::$BORG_ARCHIV"
BORG_BIN="/local/notesdata/scripts/borg"

logfile "borg mount+copy [$BORG_LOCATION] -> [$TARGET]"
echo "borg mount+copy [$BORG_LOCATION] -> [$TARGET]"

# Mount archiv
$BORG_BIN mount "$BORG_LOCATION" "$BORG_RESTORE_MOUNT"

BORG_RET=$?
if [ "$BORG_RET" = "0" ]; then
  echo "Mount: BORG OK"
else
  echo "Mount: BORG ERROR"
fi

if [ -e "$BORG_RESTORE_MOUNT$SOURCE" ]; then

  # Create directory if not present
  DIRNAME=`dirname $TARGET`

  if [ ! -e "$DIRNAME" ]; then
    mkdir -p "$DIRNAME" >> $OUTFILE
  fi

  cp "$BORG_RESTORE_MOUNT$SOURCE" "$TARGET" >> $OUTFILE
else
  echo "Cannot restore [${BORG_RESTORE_MOUNT}${SOURCE}] does not exist"
fi

if [ -r "$TARGET" ]; then
  echo "Database restored [$SOURCE] -> [$TARGET]"
else
  echo "Database NOT restored [$SOURCE] -> [$TARGET]"
fi

# Unmout the archive
$BORG_BIN umount "$BORG_RESTORE_MOUNT"

BORG_RET=$?
if [ "$BORG_RET" = "0" ]; then
  echo "Unmount: BORG OK" >> $OUTFILE
else
  echo "Unmount: BORG ERROR" >> $OUTFILE
fi

if [ -e "$TARGET" ]; then
  echo "Return: PROCESSED ($1)"
  logfile "Return: PROCESSED ($1)"
else
  echo "Return: ERROR ($1)"
  logfile "Return: ERROR ($1)"
fi

logfile

