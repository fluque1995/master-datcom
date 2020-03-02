# Select base image
FROM ubuntu

# Update machine and install python3 and pip
RUN apt-get update
RUN apt-get -y install python3 python3-pip

# Use pip to install libraries
RUN pip3 install pandas numpy scipy scikit-learn matplotlib plotly seaborn
