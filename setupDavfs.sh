#!/bin/bash
davUser=
davPassword=
mountpoint=/media/magenta
url=https://webdav.magentacloud.de

# install with no questions
DEBIAN_FRONTEND=noninteractive apt-get install -y davfs2
chmod u+s /usr/sbin/mount.davfs                           # correct the sticky bit
# add users to group davfs2
usermod -aG davfs2 pi
usermod -aG davfs2 fhem
if [ -z $davUser ]
	then
      exit
fi
# Add entry to fstab
echo "$url $mountpoint davfs noauto,users,rw 0 0" >> /etc/fstab
# save the credential for all user access
echo "$url $davUser $davPassword" >> /etc/davfs2/secrets
# or only for one user
#touch /home/<user>/.dav2fs/secrets
#chmod 0600 /home/<user>/.dav2fs/secrets
#echo "$url $davUser $davPassword" > /home/<user>/.dav2fs/secrets
