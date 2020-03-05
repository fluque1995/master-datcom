# Select base image
FROM ubuntu

# Update machine and install python3 and pip
RUN apt-get update
RUN apt-get -y install python3 python3-pip

# Use pip to install libraries
RUN pip3 install pandas numpy scipy scikit-learn matplotlib plotly seaborn

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
