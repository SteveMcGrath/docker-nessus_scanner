#!/bin/bash

if [ ! -n "${NON_PRIV_USER}" ];then
    NON_PRIV_USER=nessus
fi

if [ ! -f /opt/nessus/var/nessus/first_run ];then
    if [ "${NO_SYMLINK}" != "" ];then
        echo "-- Removing Symlinks to Log Files."
        echo "   NOTE: This will mean that Nessus will log to the disk.  These"
        echo "         logs are NOT MANAGED in any way and may cause storage"
        echo "         issues.  You have been warned."
        rm -f /opt/nessus/var/nessus/logs/nessusd.messages
        rm -f /opt/nessus/var/nessus/logs/www_server.log
        rm -f /opt/nessus/var/nessus/logs/backend.log
        rm -f /opt/nessus/var/nessus/logs/nessusd.dump
    fi

    #echo "-- Initializing Nessus daemon for database creation"
    #timeout 20 /opt/nessus/sbin/nessusd

    echo "-- New Nessus Installation, Attempting to license it using the provided configuration"
    yes | /opt/nessus/sbin/nessuscli fix --reset

    if [ "$(/opt/nessus/sbin/nessuscli managed status | grep 'Linked to' | wc -l)" == "0" ] && [ -n "${LINKING_KEY}" ];then
        echo "-- Linking Scanner to Tenable.io"
        args=" --key=${LINKING_KEY}"
        [ -n "${SCANNER_NAME}" ] && args=${args}" --name=${SCANNER_NAME}"
        [ -n "${PROXY_HOST}"   ] && args=${args}" --proxy-host=${PROXY_HOST}"
        [ -n "${PROXY_PORT}"   ] && args=${args}" --proxy-port=${PROXY_PORT}"
        [ -n "${PROXY_USER}"   ] && args=${args}" --proxy-username=${PROXY_USER}"
        [ -n "${PROXY_PASS}"   ] && args=${args}" --proxy-password=${PROXY_PASS}"
        [ -n "${PROXY_AGENT}"  ] && args=${args}" --proxy-agent=${PROXY_AGENT}"
        [ -n "${MANAGER_HOST}" ] && args=${args}" --host=${MANAGER_HOST}"        || args=${args}" --host=cloud.tenable.com"
        [ -n "${MANAGER_PORT}" ] && args=${args}" --port=${MANAGER_PORT}"        || args=${args}" --port=443"
        /opt/nessus/sbin/nessuscli managed link ${args}

    elif [ -n "${LICENSE}" ];then
        echo "-- Registering as a Nessus Pro scanner"
        /opt/nessus/sbin/nessuscli fetch --register "${LICENSE}"

    elif [ -n "${SECURITYCENTER}" ];then
        echo "-- Registering as a SecurityCenter-linked scanner"
        /opt/nessus/sbin/nessuscli fetch --security-center
    fi

    if [ ! -n "${ADMIN_PASS}" ];then
        ADMIN_PASS=$(date | md5sum | cut -d " " -f 1)
        echo "-----------------------------------------------------------------"
        echo "-----------------------------------------------------------------"
        echo "-- No Password was provided"
        echo "-- Password for ${ADMIN_USER} has been set to ${ADMIN_PASS}"
        echo "-----------------------------------------------------------------"
        echo "-----------------------------------------------------------------"
    fi

    echo -e "-- Creating the administrative user based on the provided settings"
    /usr/bin/nessus_adduser.exp "${ADMIN_USER}" "${ADMIN_PASS}" > /dev/null

    if [ -n "${NO_ROOT}" ];then
        echo "-- Reconfiguring Nessus for a non-root configuration..."
        echo "-- Creating user ${NON_PRIV_USER} to run the Nessus services..."
        useradd -r ${NON_PRIV_USER}
        usermod -a -G tty ${NON_PRIV_USER}

        echo "-- Setting the appropriate permissions for the Nessus services..."
        setcap "cap_net_admin,cap_net_raw,cap_sys_resource+eip" /opt/nessus/sbin/nessusd
        setcap "cap_net_admin,cap_net_raw,cap_sys_resource+eip" /opt/nessus/sbin/nessus-service

        echo "-- Changing the ownership of the Nessus installation to ${NON_PRIV_USER}"
        chmod 750 /opt/nessus/sbin/*
        chown -R ${NON_PRIV_USER}:${NON_PRIV_USER} /opt/nessus
    fi

    # Create the first_run file so that we know the initialization is complete.
    touch /opt/nessus/var/nessus/first_run
fi

if [ -n "${NO_ROOT}" ];then
    echo "-- Starting the Nessus service as ${NON_PRIV_USER}"
    su ${NON_PRIV_USER} -c '/opt/nessus/sbin/nessus-service --no-root'
else
    echo "-- Starting the Nessus service as root"
    /opt/nessus/sbin/nessus-service
fi
