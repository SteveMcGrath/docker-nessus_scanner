#!/bin/bash

function link_scanner {
    if [ -n "${LINKING_KEY}" ];then
        local args=" --key=${LINKING_KEY}"
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
        /opt/nessus/sbin/nessuscli fetch --register "${LICENSE}"
    fi
}

if [ "$(/opt/nessus/sbin/nessuscli managed status | grep "Linked to" | wc -l)" == "0" ] && [ -n "${LINKING_KEY}" ];then
    link_scanner
fi


/opt/nessus/sbin/nessusd