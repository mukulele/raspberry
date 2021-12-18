# Download a bunch of Scripts 
```
wget https://raw.githubusercontent.com/heinz-otto/raspberry/master/Docker/{pivccu.yml,fhem.yml,sonos.yml,deconz.yml,.env,patchEnv.sh}
```
docker-compose kann mehrere yml Dateien mit einem Aufruf verarbeiten:
```
docker-compose -f deconz.yml -f sonos.yml -f fhem.yml -f pivccu.yml up
```
