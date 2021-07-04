FROM ubuntu:20.04

COPY vsftpd_start.sh /usr/sbin/
RUN apt-get update \
    && apt-get install  -y vsftpd \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/sbin/vsftpd_start.sh

CMD /usr/sbin/vsftpd_start.sh
