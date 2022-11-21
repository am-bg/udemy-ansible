#!/bin/sh


for VM in $(VBoxManage list runningvms | awk -F\" '{print $2}' | grep -v controller);
do {
 #IP=`./mactoip.sh $VM | awk -F\. '{print $4}' # 's/ //g'`

# Get a string of the form macaddress1=xxxxxxxxxxx
var1=$(VBoxManage showvminfo $VM --machinereadable |grep macaddress1)

# Asdign macaddress1 the MAC address as a value
eval $var1

# assign m the MAC address in lower case
m=$(echo ${macaddress1}|tr '[A-Z]' '[a-z]')

# This is the MAC address formatted with : and 0n translated into n
mymac=$(echo `expr ${m:0:2}`:`expr ${m:2:2}`:`expr ${m:4:2}`:`expr ${m:6:2}`:`expr ${m:8:2}`:`expr ${m:10:2}`)
#echo "The MAC address of the virtual machine $1 is $mymac"

# Get known IP and MAC addresses
IFS=$'\n'; for line in $(arp -a); do {
#  echo $line
  IFS=' ' read -a array <<< $line
  ip=$(echo "${array[1]}"|tr "(" " "|tr ")" " ")

  if [ "$mymac" = "${array[3]}" ]; then
    echo "$ip"
    IP2=`echo $ip | awk -F\. '{print $4}' | sed 's/ //g'`
    sed -i '' -e 's/\(^'"$VM"' ansible_host=192\.168\.10\.\)[0-9]*[ ]*a/\1'"$IP2"' a/' inventory.txt
  fi
} done

} done
