FROM centos:7

RUN yum update -y \
 && yum groupinstall "Development tools" -y \
 && curl http://download.redis.io/redis-stable.tar.gz -o redis-stable.tar.gz \
 && tar xvzf redis-stable.tar.gz \
 && cd redis-stable \
 && make MALLOC=libc redis-cli

RUN if [ "$(uname -a | tr ' ' '\n' | grep arm)" ]; then echo "[epel]" >> /etc/yum.repos.d/epel.repo && echo "name='Epel rebuild for armhfp'" >> /etc/yum.repos.d/epel.repo && echo "baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/" >> /etc/yum.repos.d/epel.repo && echo "enabled=1" >> /etc/yum.repos.d/epel.repo && echo "gpgcheck=0" >> /etc/yum.repos.d/epel.repo; else yum -y install epel-release; fi

RUN yum install -y jq hostname \
 && mkdir -p /opt/hnt_monitor \
 && rm -rf /tmp/* \
 && yum clean all -y

COPY HISTORY.md /
COPY src/ /opt/hnt_monitor/
COPY build/docker/hnt_monitor/entrypoint /

RUN chmod 755 /entrypoint

ENTRYPOINT ["./entrypoint"]
