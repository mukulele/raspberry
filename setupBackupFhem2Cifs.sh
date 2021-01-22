#!/bin/bash
# Please check the Definitions for FHEM at button lines: no variables will be used there!
echo "Nothing done, remove or comment this line after configuration!"
echo "Please run this script with sudo!"; exit
################################## Configuration needed !!!
# some basic setup for script names for files, folders, Server, url to FHEM and user account
server='backupServerName'
share="//$server/Sicherung"
mdir='/mnt/Sicherung'
fhemDir='/opt/fhem'
docker=0
url=8083
scriptName='backupFhem.sh'
scriptName2='cronBackupFhem.sh'
setupDir='/usr/local/bin' 
cmdBackup="/bin/bash $setupDir/$scriptName $fhemDir $mdir"
fcred='smbcredentials'
############### Setup system part
# create file with user account
echo 'username=user' > /usr/.$fcred
echo 'password=password' >> /usr/.$fcred
################################## Configuration End
# check if fhemcl exists
file="fhemcl.sh"
fhemcl="$setupDir/$file"
if [ ! -e $fhemcl ]
then
    echo "$file is missing"
    wget -O $fhemcl https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file
    chmod +x $fhemcl
fi
# add line to fstab
if grep "$share $mdir" /etc/fstab 2>&1>/dev/null;then
   echo "entry in fstab already exists"
else
   echo "$share $mdir cifs noauto,users,credentials=/usr/.$fcred 0 0" >> /etc/fstab
fi
# create folders, connection test
mkdir -p "$mdir"
if mount "$mdir"
then
    mkdir ${mdir}/fhem
    umount "$mdir"
else
    echo "Error mount $mdir"
    echo "Setup canceled"; exit
fi

# write the main Script to the setup folder
cat <<EOF > $setupDir/$scriptName
#!/bin/bash
url=$url
fhemcl=$fhemcl
EOF
cat <<'EOF' >> $setupDir/$scriptName
qpath=$1
dpath=$2
LOG=/var/log/backupFhem.log
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
EOF
############### Setup FHEM Part
#write definitions to FHEM
cat <<'EOF' | $fhemcl $url
define BackupFhem dummy
attr BackupFhem room backup
attr BackupFhem userReadings platte:gesichert {qx(df ./backup |sed -e '1d')},\
percent:gesichert {my $s=(split ' ',qx(df ./backup |sed -e '1d'))[-2] ;;$s=~ s/\D//g;;$s}
define backupFhemlog FileLog /var/log/backupFhem.log fakelog
attr backupFhemlog room backup
EOF
# fhem is used to control backup
if [ ! $docker ]
then
cat <<EOF | $fhemcl $url
define backupCopy DOIF ([$server] eq "present") ("$cmdBackup")
attr backupCopy room backup
attr backupCopy wait 120
EOF
fi
# because mount is not easy - a cronjob is used
if [ $docker ]
then
cat <<EOF > $setupDir/$scriptName2
#!/bin/bash
fhemcl=$fhemcl
url=$url
cmd="$cmdBackup"
EOF
cat <<'EOF' >> $setupDir/$scriptName2
server=$1
port=$2
lpath='/var/log'
log="$lpath/cronTestServer.log"
if [ ! -e $lpath/$server ]
then
  touch $lpath/$server  #create the memoryfile
fi
#echo "setreading BackupFhem cron $(date)" |$fhemcl $url
if [ "$(cat $lpath/$server)" = "off" ]; then
  #echo "Inhalt der Datei ist off" >> $log
  echo "setreading BackupFhem cron off" |$fhemcl $url
  if /usr/bin/nc -z $server $port 2>/dev/null; then
    #echo "$server ist auf $port erreichbar" >> $log
    echo "setreading BackupFhem cron $server:$port on" |$fhemcl $url
    echo "on" > $lpath/$server
    #echo $cmd >> $log
    $cmd
  fi
else
  if /usr/bin/nc -z $server $port 2>/dev/null; then
      #echo "2. Test $server ist auf $port erreichbar" >> $log
      echo "setreading BackupFhem cron $server:$port on" |$fhemcl $url
  else
      #echo "2. Test $server ist auf $port nicht erreichbar" >> $log
      echo "setreading BackupFhem cron $server:$port off" |$fhemcl $url
      echo "off" > $lpath/$server
  fi
fi
EOF
echo "Jetzt noch mit crontab -e einen Job einrichten"
echo "* * * * * /bin/bash $setupDir/$scriptName2 $server Portnummer"
fi
