for ziel in ${ziel_host} $(ping -4c 1 ${ziel_host} | awk 'NR==1{gsub(/\(|\)/,"",$3);print $3}') ; do
  yes '' | ssh-keygen -R \${ziel}
  ssh-keyscan -t ed25519 \${ziel} 2>/dev/null >> ~/.ssh/known_hosts
done
if ! ls ~/.ssh/id_rsa.pub >/dev/null; then
    ssh-keygen -f ~/.ssh/id_rsa -P "" -t rsa
  else
    echo "rsa key already in place"
fi
sort -u ~/.ssh/known_hosts -o ~/.ssh/known_hosts
