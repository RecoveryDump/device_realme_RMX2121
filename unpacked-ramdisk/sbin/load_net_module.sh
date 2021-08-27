#!/sbin/sh
#***********************************************************
#** Copyright (C), 2008-2016, OPPO Mobile Comm Corp., Ltd.
#** VENDOR_EDIT
#**
#** Version: 1.0
#** Date : 2020/03/17
#** Author : JiaoBo@PSW.CN.WiFi.Basic.Custom.2870100, 2020/03/17
#** add for: recovery support wifi update
#**
#** ---------------------Revision History: ---------------------
#**  <author>    <data>       <version >       <desc>
#**  Jiao.Bo     2020/03/17     1.0     build this module
#****************************************************************/

# function: start common depend on process
commonSetting() {
    chmod 755 /system/bin/ip6tables
    chmod 755 /system/bin/iptables
    chmod 755 /system/bin/netutils-wrapper-1.0
    chmod 755 /system/bin/sh
    chmod 755 /system/bin/toybox
    toybox start servicemanager
    toybox start hwservicemanager
    toybox chcon u:object_r:netd_exec:s0 /sbin/netd

    #mount nvdata
    mkdir -p /mnt/vendor/nvdata
    mount /dev/block/platform/bootdevice/by-name/nvdata /mnt/vendor/nvdata

    mkdir -p /data/misc/wifi/sockets
    busybox chown 1010:1010 /data/misc/wifi/sockets
    busybox chmod 0770 /data/misc/wifi/sockets
    toybox chcon u:object_r:wpa_socket:s0 /data/misc/wifi/sockets
    touch /data/misc/wifi/wpa_supplicant.conf
    busybox chown 1010:1010 /data/misc/wifi/wpa_supplicant.conf
    busybox chmod 0770 /data/misc/wifi/wpa_supplicant.conf
    sleep 1
}

#step1 set common settings
commonSetting
#step2 remove file wmtWifi when wmtWifi is not an char device
charDevName="/dev/wmtWifi"
if [ -c "$charDevName" ]; then
    echo "$charDevName is char device"
else
    echo "$charDevName is not char device"
    rm -rf $charDevName
fi
#step3 insmod driver
platform=`getprop ro.board.platform`
echo "platform = $platform"
if [ "$platform" = "mt6885" ]; then
    toybox stop conninfra_loader
    /sbin/conninfra_loader &
    insmod /sbin/conninfra.ko&
    #insmod /sbin/bt_drv.ko&
    #insmod /sbin/wmt_chrdev_wifi.ko&
    #insmod /sbin/wlan_drv_gen4m.ko&
elif [ "$platform" = "mt6873" -o "$platform" = "mt6853" ]; then
    toybox stop wmt_loader
    toybox stop wmt_launcher
    /vendor/bin/wmt_loader &
    /vendor/bin/wmt_launcher -p /vendor/firmware/ &
    insmod /sbin/wmt_drv.ko &
    #insmod /sbin/wmt_chrdev_wifi.ko &
    #insmod /sbin/wlan_drv_gen4m.ko &
elif [ "$platform" = "mt6853" ]; then
    toybox stop wmt_loader
    toybox stop wmt_launcher
    /vendor/bin/wmt_loader &
    /vendor/bin/wmt_launcher -p /vendor/firmware/ &
    insmod /sbin/wmt_drv.ko &
    #insmod /sbin/wmt_chrdev_wifi.ko &
    #insmod /sbin/wlan_drv_gen4m.ko &
else
    echo "this wifi obj is not support."
fi
