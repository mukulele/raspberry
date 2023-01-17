#!/bin/sh
# remove and set the public key from hostnames as arguments
# create a new public for the current user if not exists
# remove doubles in known_hosts - ist das nicht unnötig?
key_version=ed25519 #rsa, ed25519, dsa (unsafe)
for arg in $* ; do
  yes '' | ssh-keygen -R ${arg}
  ssh-keyscan -t ed25519 ${arg} 2>/dev/null >> ~/.ssh/known_hosts
done
if ! ls ~/.ssh/id_${key_version}.pub >/dev/null; then
    ssh-keygen -f ~/.ssh/id_${key_version} -P "" -t ${key_version}
  else
    echo "public key of type ${key_version} already in place"
fi
#sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
cat ~/.ssh/id_${key_version}.pub
