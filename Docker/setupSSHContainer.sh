#!/bin/sh
# remove and set the public key from hostnames as arguments
# create a new public for the current user if not exists
# remove doubles in known_hosts - ist das nicht unnötig?
for arg in $* ; do
  yes '' | ssh-keygen -R ${arg}
  ssh-keyscan -t ed25519 ${arg} 2>/dev/null >> ~/.ssh/known_hosts
done
if ! ls ~/.ssh/id_rsa.pub >/dev/null; then
    ssh-keygen -f ~/.ssh/id_rsa -P "" -t rsa
  else
    echo "rsa key already in place"
fi
sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
cat ~/.ssh/id_rsa.pub
