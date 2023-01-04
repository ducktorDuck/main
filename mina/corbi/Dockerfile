# syntax=docker/dockerfile:1
FROM ubuntu:latest
WORKDIR /
COPY . .
RUN apt update && apt upgrade
RUN apt install fail2ban
RUN systemctl enable fail2ban && systemctl start fail2ban
CMD 
EXPOSE 3000
