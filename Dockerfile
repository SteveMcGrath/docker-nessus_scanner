FROM centos:7

ENV LINKING_KEY	 ""
ENV SCANNER_NAME ""
ENV MANAGER_HOST ""
ENV MANAGER_PORT ""
ENV PROXY_HOST	 ""
ENV PROXY_PORT	 ""
ENV PROXY_USER	 ""
ENV PROXY_PASS	 ""
ENV PROXY_AGENT	 ""
ENV LICENSE      ""

COPY nessus.sh /usr/bin
COPY download.py /tmp
COPY supervisor.conf /etc

RUN chmod 755 /usr/bin/nessus.sh					\
	&& python /tmp/download.py						\
	&& yum -y -q install epel-release 				\
	&& yum -y -q install /tmp/Nessus.rpm supervisor	\
	&& yum -y -q clean all							\
	&& chmod 755 /usr/bin/nessus.sh					\
	&& rm -f /tmp/Nessus.rpm						\
	&& rm -f /opt/nessus/var/nessus/*.db*			\
	&& rm -f /opt/nessus/var/nessus/master.key 		\
	&& rm -f /opt/nessus/var/nessus/uuid			\
	&& rm -f /tmp/*

VOLUME /opt/nessus/var/nessus
EXPOSE 8834

CMD ["/usr/bin/supervisord", "-nc", "/etc/supervisor.conf"]