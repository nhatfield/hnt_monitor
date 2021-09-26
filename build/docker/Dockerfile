FROM centos:7

RUN yum update -y \
 && yum -y install epel-release \
 && yum update -y \
 && yum install -y jq \
 && mkdir -p /opt/hnt_monitor

COPY src/ /opt/hnt_monitor/
COPY build/docker/entrypoint /

RUN chmod 755 /entrypoint

WORKDIR /opt/hnt_monitor

ENTRYPOINT ["./entrypoint"]
