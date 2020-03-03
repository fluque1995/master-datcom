FROM mariadb/server:10.3

# Change bind address
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes

COPY ./init.sql /docker-entrypoint-init.d/
