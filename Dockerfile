# Dockerfile
FROM amazonlinux:2023

# Install necessary dependencies
RUN yum update -y && yum install -y \
    make \
	cmake \
    zip tar gzip \
    gcc \
    aws-cli

# Set up the working directory
WORKDIR /var/task

RUN chown root:root /tmp && \
  chmod 1777 /tmp && \
  yum install -y glibc-langpack-en && \
  yum groupinstall -y development && \
  yum install -y which clang cmake python-devel python3-devel && \
  dnf install -y docker pip && \
  yum clean all 