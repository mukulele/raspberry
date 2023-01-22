Working in progress ...
## Get Values with vcgencmd
official [Documentation](https://www.raspberrypi.com/documentation/computers/os.html#vcgencmd)
```
Temp=$(vcgencmd measure_temp | cut -f2 -d=)
Clockspeed=$(vcgencmd measure_clock arm | awk -F"=" '{printf ("%0.0f",$2/1000000); }' )
Corespeed=$(vcgencmd measure_clock core | awk -F"=" '{printf ("%0.0f",$2/1000000); }' )
Health=$(vcgencmd get_throttled | cut -f2 -d=)
CoreVolt=$(vcgencmd measure_volts | cut -f2 -d=)
```
## Translate Values to human readable
For more complex operation functions will be easier to use.
```
  throttled () {
    code=$1
    output=
    if (( ($code & 0x1) != 0 )) ; then output='Under-voltage detected' ;fi
    if (( ($code & 0x2) != 0 )) ; then output='Arm frequency capped' ;fi
    if (( ($code & 0x4) != 0 )) ; then output='Currently throttled '${output} ;fi
    if (( ($code & 0x8) != 0 )) ; then output='Soft temperature limit active' ;fi
    if (( ($code & 0x10000) != 0 )) ; then output='Under-voltage has occurred '${output} ;fi
    if (( ($code & 0x20000) != 0 )) ; then output='Arm frequency capping has occurred ' ;fi
    if (( ($code & 0x40000) != 0 )) ; then output='Throttling has occurred '${output} ;fi
    if (( ($code & 0x80000) != 0 )) ; then output='Soft temperature limit has occurred '${output} ;fi
    if [ -z "$output" ] ; then echo 'ok' ; else echo $output ; fi
  }
Health=throttled $(vcgencmd get_throttled | cut -f2 -d=)
```
## Get information from system files
 /etc/os-release is multilined and '=' delimited
```
distribution="$( cat /etc/os-release| awk -F"=" '$0 ~ /PRETTY_NAME/ {print $2}')"
```
Inside subdirectories below /proc/
/proc/version is single line, not realy structured
```
firmware=$( cat /proc/version |grep -oE '#[0-9]+')
```
cat /proc/cpuinfo is a formatted multiline table, ':' delimited
```
Processor="$(cat /proc/cpuinfo|awk -F": '$0 ~ /Hardware/ {print $2}')"
Model="$(cat /proc/cpuinfo|awk -F": " '$0 ~ /Model/ {print $2}')"
```
cat /proc/meminfo is a formatted multiline table, ':' and space delimited
```
memory_total=$(($(cat /proc/meminfo|grep MemTotal |awk '{print $2}')/1024))
memory_free=$(($(cat /proc/meminfo|grep MemFree |awk '{print $2}')/1024))
memory_available=$(($(cat /proc/meminfo|grep MemAvailable |awk '{print $2}')/1024))
swap_total=$(($(cat /proc/meminfo|grep SwapTotal |awk '{print $2}')/1024))
swap_used=$(($(cat /proc/meminfo|grep SwapFree |awk '{print $2}')/1024))
```
loadavg returns multivalue line [loadavg](https://linuxwiki.de/proc/loadavg) The command uptime gives also this same values
```
load1,load5,load15=$(cat /proc/loadavg|awk '{print $1" "$2" "$3}')
```
uptime is also returned from /proc
```
uptime=$( cat /proc/uptime|awk '{print $1}')
```
uname is controlled by argument and returns a single line. uname --help
```
kernel_version="$( uname -msr )"
```
Information from filesystem will get by the df command
```
sdcard_root_total=$(($(df /|grep /dev/root|awk '{print $2}')/1024))
sdcard_boot_total=$(($(df /boot|grep /dev/|awk '{print $2}')/1024))
sdcard_root_used=$(($(df /|grep /dev/root|awk '{print $3}')/1024))
sdcard_boot_used=$(($(df /boot|grep /dev/|awk '{print $3}')/1024))
```
Information about network
```
net_received=$( cat /sys/class/net/eth0/statistics/rx_bytes)
net_send=$( cat /sys/class/net/eth0/statistics/tx_bytes)
```
thousands of values will be available in the /sys/devices/ tree


After the apt update -y command, the number of availlable packages
```
packages=$(($(apt list --upgradeable 2>/dev/null|wc -l )-1))
```

