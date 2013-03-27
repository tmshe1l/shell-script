#!/bin/sh
#version: 1.0
#by fanyouchang  at 2010-01-05
#http://www.youchang.net
#Last Updated: 2012-12-28


# Set Path
logs_dir="/opt/data/logs"

if [ ! -d $logs_dir/temporary.logfile ]; then
    mkdir -p $logs_dir/temporary.logfile
    ln -s $logs_dir/temporary.logfile /opt/sbin
fi

path=/opt/sbin/temporary.logfile

netstat -ant |grep '\<80\>' |grep SYN_RECV |awk '{print $5}' |awk -F\: '{print $1}'|sort |uniq -c |sort > $path/kstec-syn_ip_drop-ctl_ipFile

echo "-------------------- TIME_WAIT ---------------------------" >> $path/kstec-syn_ip_drop-ctl_ipFile
netstat -antup |grep '\<80\>' |grep TIME_WAIT |awk '{print $5}' |awk -F\: '{print $4}'|sort |uniq -c |sort >> $path/kstec-syn_ip_drop-ctl_ipFile
echo "-------------------- ESTABLISHED -------------------------" >> $path/kstec-syn_ip_drop-ctl_ipFile
netstat -antup |grep '\<80\>' |grep ESTABLISHED |awk '{print $5}' |awk -F\: '{print $4}'|sort |uniq -c |sort >> $path/kstec-syn_ip_drop-ctl_ipFile


echo " " >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log
echo 时间：`date +%Y-%m-%d_%H:%M:%S`>> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log
echo "-----------------------------------------------" >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log

while read LINE
do
    syn_num=`echo $LINE |awk '{print $1}'`
    drop_ip=`echo $LINE |awk '{print $2}'`
    hacker_ip_count=`/sbin/iptables -L -vn |grep $drop_ip |wc -l`
    allow_ip=`/opt/sbin/kstec-syn_ip_drop-ctl.IP_allow |grep $drop_ip |wc -l`


    if [[ $syn_num -gt 30 || $hacker_ip_count -lt 1 || $allow_ip -lt 1 ]]; then
       shift
       /sbin/iptables -I INPUT -p tcp -s $drop_ip --syn -j DROP
       echo $syn_num $drop_ip >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log


    elif [ $syn_num -gt 30 || $allow_ip -eq 1 ]; then
        shift
        echo 时间：`date +%Y-%m-%d_%H:%M:%S`>> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log
        echo "------------------------------------" >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log
        echo $syn_num $drop_ip >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log
        echo "IP_allow's connection info print ......[OK]" >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log
        echo " " >> $path/kstec-syn_ip_drop-ctl_ipFile_drop.log

    else
        echo "Welcome to vist the http://www.youchang.net!!!"
    fi
done<$path/kstec-syn_ip_drop-ctl_ipFile
