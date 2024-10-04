FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y git

# Clone your GitHub repository
RUN git clone https://github.com/beatquantum/docker.git /tmp/repo

# Copy the sysctl.conf file to the appropriate location
RUN cp /tmp/repo/sysctl.conf /etc/sysctl.conf

# Apply the sysctl settings
RUN sysctl -p

# Clean up
RUN rm -rf /tmp/repo

CMD ["bash"]
