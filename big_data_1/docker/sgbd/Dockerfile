FROM mariadb:10.3

ENV MYSQL_ROOT_PASSWORD root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt -y update
RUN apt install -y nano

## Define default command.
CMD ["mysqld_safe"]

## Expose ports.
EXPOSE 3306
