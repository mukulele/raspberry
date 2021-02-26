#!/bin/bash
url='8083'
qpath=$1
dpath=$2
LOG=./backupFhem.log
# check if fhemcl exists
file="fhemcl.sh"
fhemcl="./$file"
if [ ! -e $fhemcl ]
then
    echo "$file is missing"
    wget -O $fhemcl https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file
    chmod +x $fhemcl
fi
#
{
date
# mount, sync
if mount "$dpath"
then
    # only piping works inside crontab
    echo "set BackupFhem gestartet"|$fhemcl $url
    if rsync -rut ${qpath}/backup ${qpath}/restoreDir ${dpath}/fhem/$(hostname)
    then
       echo "set BackupFhem gesichert"|$fhemcl $url
    else
       echo "set BackupFhem RsyncError"|$fhemcl $url
    fi
    umount "$dpath"
else
    echo "set BackupFhem MountError"|$fhemcl $url
fi
} >> $LOG 2>&1
