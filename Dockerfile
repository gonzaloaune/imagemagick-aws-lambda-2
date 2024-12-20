# Dockerfile
FROM amazonlinux:2023

# Install necessary dependencies
RUN yum update -y && yum install -y \
    make \
	cmake \
    zip \
    gcc \
    aws-cli \
    ImageMagick

# Set up the working directory
WORKDIR /var/task

# Entrypoint will be passed from the Makefile or overridden as needed
ENTRYPOINT ["/bin/bash"]
