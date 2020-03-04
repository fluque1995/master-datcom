FROM mariadb/server:10.3

# Change bind address
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
ENV MYSQL_ROOT_PASSWORD rootpass
ENV MYSQL_USER datcom2020
ENV MYSQL_PASSWORD datcom2020
ENV MYSQL_DATABASE library

COPY ./init.sql /docker-entrypoint-initdb.d

EXPOSE 3306
