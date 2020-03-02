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
