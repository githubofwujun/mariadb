FROM centos:7
MAINTAINER Severalnines <ashraf@severalnines.com>

#new add
ENV LANG = en_US.UTF-8
ENV TZ = 'Asia/Shanghai'

#RUN echo -e "[mariadb]\nname = MariaDB\nbaseurl = http://yum.mariadb.org/10.2/centos7-amd64/\nenabled = 1\ngpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck = 1"  > /etc/yum.repos.d/MariaDB.repo
RUN echo -e "[mariadb]\nname = MariaDB\nbaseurl = http://yum.mariadb.org/10.1/centos7-amd64\nenabled = 1\ngpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck = 1"  > /etc/yum.repos.d/MariaDB.repo

RUN rpmkeys --import https://www.percona.com/downloads/RPM-GPG-KEY-percona && \
	yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
#add datadir for backup
#RUN yum install -y crontabs bind-utils telnet which MariaDB-server MariaDB-client socat percona-xtrabackup && \
# 	yum clean all
RUN yum install -y crontabs bind-utils telnet which MariaDB-server MariaDB-client socat percona-xtrabackup && \
	mkdir -p /data/backup && mkdir -p /data/restore && rm -rf /var/cache/yum && yum clean all 

ADD my.cnf /etc/my.cnf
VOLUME /var/lib/mysql

COPY entrypoint.sh /entrypoint.sh
COPY report_status.sh /report_status.sh
COPY healthcheck.sh /healthcheck.sh
COPY jq /usr/bin/jq
RUN chmod a+x /usr/bin/jq

EXPOSE 3306 4567 4568
ONBUILD RUN yum update -y
HEALTHCHECK --interval=10s --timeout=3s --retries=15 \
	CMD /bin/sh /healthcheck.sh || exit 1

ENTRYPOINT ["/entrypoint.sh"]

