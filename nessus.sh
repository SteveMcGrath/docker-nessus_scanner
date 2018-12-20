#!/bin/bash

if [ "$(/opt/nessus/sbin/nessuscli fix --list | grep 'do not exist yet' | wc -l)" -ne "0" ];then
    echo "-- New Nessus Installation, Attempting to license it using the provided configuration"
    if [ "$(/opt/nessus/sbin/nessuscli managed status | grep 'Linked to' | wc -l)" == "0" ] && [ -n "${LINKING_KEY}" ];then
        echo "-- Linking Scanner to Tenable.io"
        args=" --key=${LINKING_KEY}"
        [ -n "${SCANNER_NAME}" ] && args=${args}" --name=${SCANNER_NAME}"
        [ -n "${PROXY_HOST}"   ] && args=${args}" --proxy-host=${PROXY_HOST}"
        [ -n "${PROXY_PORT}"   ] && args=${args}" --proxy-port=${PROXY_PORT}"
        [ -n "${PROXY_USER}"   ] && args=${args}" --proxy-username=${PROXY_USER}"
        [ -n "${PROXY_PASS}"   ] && args=${args}" --proxy-password=${PROXY_PASS}"
        [ -n "${PROXY_AGENT}"  ] && args=${args}" --proxy-agent=${PROXY_AGENT}"
        [ -n "${MANAGER_HOST}" ] && args=${args}" --host=${MANAGER_HOST}"           || args=${args}" --host=cloud.tenable.com"
        [ -n "${MANAGER_PORT}" ] && args=${args}" --port=${MANAGER_PORT}"           || args=${args}" --port=443"
        /opt/nessus/sbin/nessuscli managed link ${args}
    elif [ -n "${LICENSE}" ];then
        echo "-- Registering as a Nessus Pro scanner"
        /opt/nessus/sbin/nessuscli fetch --register "${LICENSE}"
    elif [ -n "${SECURITYCENTER}" ];then
        echo "-- Registering as a SecurityCenter-linked scanner"
        /opt/nessus/sbin/nessuscli fetch --security-center
    fi
fi

if [ -n "${ADMIN_USER}" ] && [ -n "${ADMIN_PASS}" ];then
    if [[ ! "$(/opt/nessus/sbin/nessuscli lsuser)" =~ "${ADMIN_USER}" ]];then
        echo "-- Creating the administrative user based on the provided settings"
        /usr/bin/nessus_adduser.exp "${ADMIN_USER}" "${ADMIN_PASS}" > /dev/null
    fi
fi

if [[ -n "${NO_ROOT}" ]];then
    USER=nonprivuser
    if [[ -n "${NON_PRIV_USER}" ]];then
        USER="${NON_PRIV_USER}"
        echo "-- Using user-specified non-privileged user ($USER)"
    else
        echo "-- No non-priviledged user specified; using default ($USER)"
    fi

    echo "-- Updating files to support --no-root"
    # https://docs.tenable.com/nessus/6_9/Content/LinuxNonPrivileged.htm
    useradd -r $USER
    setcap "cap_net_admin,cap_net_raw,cap_sys_resource+eip" /opt/nessus/sbin/nessusd
    setcap "cap_net_admin,cap_net_raw,cap_sys_resource+eip" /opt/nessus/sbin/nessus-service
    chmod 750 /opt/nessus/sbin/*
    chown -R $USER:$USER /opt/nessus
    echo "-- Starting the Nessus service with --no-root"
    su - $USER -c '/opt/nessus/sbin/nessus-service --no-root'
else
    echo "-- Starting the Nessus service"
    /opt/nessus/sbin/nessus-service
fi
