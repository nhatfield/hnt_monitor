FROM centos:7

# RUN echo "[epel]" >> /etc/yum.repos.d/epel.repo \
# && echo "name='Epel rebuild for armhfp'" >> /etc/yum.repos.d/epel.repo \
# && echo "baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/" >> /etc/yum.repos.d/epel.repo \
# && echo "enabled=1" >> /etc/yum.repos.d/epel.repo \
# && echo "gpgcheck=0" >> /etc/yum.repos.d/epel.repo 

RUN yum update -y \
 && yum groupinstall "Development tools" -y \
 && curl http://download.redis.io/redis-stable.tar.gz -o redis-stable.tar.gz \
 && tar xvzf redis-stable.tar.gz \
 && cd redis-stable \
 && make MALLOC=libc redis-cli 

RUN yum update -y \
 && yum -y install epel-release \
 && yum update -y \
 && yum install -y jq \
 && mkdir -p /opt/hnt_monitor \
 && rm -rf /tmp/* \
 && yum clean all -y

COPY HISTORY.md /
COPY src/ /opt/hnt_monitor/
COPY build/docker/hnt_monitor/entrypoint /

RUN chmod 755 /entrypoint

ENTRYPOINT ["./entrypoint"]
