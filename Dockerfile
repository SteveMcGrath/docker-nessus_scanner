FROM centos:7

ENV LINKING_KEY  ""
ENV SCANNER_NAME ""
ENV MANAGER_HOST ""
ENV MANAGER_PORT ""
ENV PROXY_HOST   ""
ENV PROXY_PORT   ""
ENV PROXY_USER   ""
ENV PROXY_PASS   ""
ENV PROXY_AGENT  ""
ENV LICENSE      ""
ENV ADMIN_USER   ""
ENV ADMIN_PASS   ""

COPY nessus.sh nessus_adduser.exp /usr/bin/
COPY yum.repo /etc/yum.repos.d/Tenable.repo
COPY gpg.key /etc/pki/rpm-gpg/RPM-GPG-KEY-Tenable

RUN yum -y -q install Nessus                        \
    && yum -y -q clean all                          \
    && chmod 755 /usr/bin/nessus.sh                 \
    && chmod 755 /usr/bin/nessus_adduser.exp        \
    && rm -f /opt/nessus/var/nessus/*.db*           \
    && rm -f /opt/nessus/var/nessus/master.key      \
    && rm -f /opt/nessus/var/nessus/uuid            \
    && rm -f /tmp/*

VOLUME /opt/nessus/var/nessus
EXPOSE 8834

CMD ["/usr/bin/nessus.sh"]