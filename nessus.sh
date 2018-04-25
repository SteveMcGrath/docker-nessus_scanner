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

echo "-- Starting the Nessus service"
/opt/nessus/sbin/nessus-service
