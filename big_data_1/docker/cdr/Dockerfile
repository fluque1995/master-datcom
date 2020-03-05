# Select base image
FROM ubuntu

# Set variable to avoid interaction
ARG DEBIAN_FRONTEND=noninteractive

# Update image and install R
RUN apt update
RUN apt -y upgrade
RUN apt install -y r-base

# Installation of packages needed for next step
RUN apt install -y curl libcurl4-openssl-dev libxml2-dev libssl-dev

# Install packages inside R
RUN Rscript -e 'install.packages(c("caret", "ggplot2", "tidyverse", "RSNNS", "frbs", "FSinR", "forecast"))'

# Install SSH daemon
RUN apt install -y openssh-server

# Create dir for SSH, add user and set passsword
RUN mkdir /var/run/sshd
RUN useradd datcom2020 -s /bin/bash -d /home/datcom2020 -m
RUN echo 'datcom2020:datcom2020' | chpasswd

# Port expose
EXPOSE 22

# Set SSH daemon as default command
CMD ["/usr/sbin/sshd", "-D"]
