FROM drakkan/sftpgo:2.5.x-alpine as stage1

FROM alpine:latest as stage2

SHELL ["/bin/busybox", "sh", "-c"]

COPY --from=stage1 /usr/local/bin/sftpgo /bin/sftpgo

RUN echo -e "root:x:0:\nuser:x:1000:" > /etc/group
RUN echo -e "root:x:0:0:root:/:/bin/ash\nuser:x:1000:1000:user:/home:/bin/sh" > /etc/passwd
RUN echo -e "root:*::0:::::\nuser:*::0:::::" > /etc/shadow

RUN apk add --update --no-cache rsync
RUN apk del scanelf libc-utils

RUN rm -rf /etc/alpine-release /etc/crontabs /etc/issue /etc/os-release /etc/fstab /etc/inittab /etc/logrotate.d /etc/modprobe.d /etc/modules /etc/motd /etc/network /etc/rsyncd.conf /mnt /media /opt /root /run /srv /tmp /usr/local /etc/periodic /etc/opt /etc/mtab /etc/modules-load.d /etc/init.d /etc/conf.d 
RUN rm -rf /usr/share /var
RUN mkdir -p /var/lib/apk; 

RUN find / -type d -exec chmod -r {} \;
RUN chmod -r /

RUN chown 1000:1000 /home
RUN chmod 755 /home

### Optional: Remove package management
#RUN apk del apk-tools ca-certificates-bundle libcrypto3 libssl3
### Alternative: remove all management tools
#RUN find /bin /sbin /usr/bin /usr/sbin -type l -exec busybox sh -c 'if [ "$(busybox readlink -f "{}")" = "/bin/busybox" ]; then busybox rm -f "{}"; fi' \;
#RUN apk del busybox alpine-baselayout alpine-baselayout-data alpine-keys apk-tools ca-certificates-bundle libcrypto3 libssl3 
###

FROM scratch
COPY --from=stage2 . .

