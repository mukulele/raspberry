# Please check the Definitions for FHEM at button lines: no variables will be used there!
echo "Nothing done, remove or comment this line after configuration!"
echo "Please run this script with sudo!"; exit
################################## Configuration needed !!!
# some basic setup for script names for files, folders, Server, url to FHEM and user account
fcred='smbcredentials'
share='//Server1/Sicherung'
mdir='/mnt/Sicherung'
url=8083
############### Setup system part
# create file with user account
echo 'username=UserName' > /usr/.$fcred
echo 'password=Userpassword' >> /usr/.$fcred
################################## Configuration End

# add line to fstab 
echo "$share $mdir cifs noauto,users,credentials=/usr/.$fcred 0 0" >> /etc/fstab

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

# write the main Script to the FHEM folder 
echo "url=$url" > /opt/fhem/backupFhem.sh
cat <<'EOF' >> /opt/fhem/backupFhem.sh
qpath=$1
dpath=$2
LOG=backupFhem.log
if [ -d "log" ];then LOG="log/$LOG";fi
# check if fhemcl exists
file=fhemcl.sh
{
date
if [ ! -e $file ]
then
    echo "$file is missing"
    wget https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file
    chmod +x $file
fi
# mount, sync 
if mount "$dpath"
then
    bash fhemcl.sh $url "set BackupFhem gestartet"
    if rsync -rut ${qpath}/backup ${qpath}/restoreDir ${dpath}/fhem/$(hostname)
    then
       bash fhemcl.sh $url "set BackupFhem gesichert"
    else
       bash fhemcl.sh $url "set BackupFhem RsyncError"
    fi
    umount "$dpath"
else
    bash fhemcl.sh $url "set BackupFhem MountError"
fi
} >> $LOG 2>&1
EOF
############### Setup FHEM Part
# test if HTTP client is available
if [ ! -e $file ]
then
    echo "$file is missing"
    wget https://raw.githubusercontent.com/heinz-otto/fhemcl/master/$file
    chmod +x $file
fi
#write definitions to FHEM
cat <<EOF | bash fhemcl.sh $url
define BackupFhem dummy
attr BackupFhem room backup
define backupFhemlog FileLog ./log/backupFhem.log fakelog
attr backupFhemlog room backup
define backupCopy DOIF ([Server1] eq "present") ("bash backupFhem.sh . $mdir")
attr backupCopy room backup
attr backupCopy wait 120
EOF
