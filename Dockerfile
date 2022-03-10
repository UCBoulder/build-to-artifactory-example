FROM registry.access.redhat.com/ubi7/ubi:latest
LABEL maintainer="Adam W Zheng <wazh7587@colorado.edu>"

ARG S6_OVERLAY_VERSION=3.1.0.1

#Disable service timeout
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

#Add s6-overlay process supervisor
ADD ["https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz", "/tmp"]
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD ["https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz", "/tmp"]
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

#Install demo webserver
RUN yum -y install rh-nginx120 openssl hostname

#Redirect nginx logs
RUN ln -sf /dev/stdout /var/opt/rh/rh-nginx120/log/nginx/access.log \
 && ln -sf /dev/stderr /var/opt/rh/rh-nginx120/log/nginx/error.log

#Copy s6-supervisor source definition directory into the container
COPY ["etc/s6-overlay/", "/etc/s6-overlay/"]

#Copy base nginx.conf
COPY ["etc/opt/rh/rh-nginx120/nginx/nginx.conf", "/etc/opt/rh/rh-nginx120/nginx/nginx.conf"]

#Cleanup
RUN yum -y update && yum clean all && rm -rf /var/cache/yum && > /var/log/yum.log

#Port Metadata
EXPOSE 80/tcp
EXPOSE 443/tcp

#Simple Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=600s --retries=3 CMD curl http://localhost:80/ || exit 1

ENTRYPOINT ["/init"]
