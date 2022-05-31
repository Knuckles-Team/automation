# docker run -v /mnt:/mnt -it name-of-image bash
FROM ubuntu:latest
COPY bash /bash
RUN chmod +x /bash/system-manager
RUN bash /bash/system-manager -u -p
