FROM ubuntu:18.04

# Set work directory
WORKDIR /

# Install required packages
RUN  apt-get update  && apt-get  install mdadm nvme-cli sysstat net-tools fio  iperf3 -y

# Create required directories
RUN mkdir -p /templates && mkdir -p /logs

# Copy files
COPY stat-run.sh /
COPY wait.sh / 
COPY fio_job_template.sh /

# Run the test
RUN chmod u+x fio_job_template.sh
RUN chmod u+x stat-run.sh
CMD ["./stat-run.sh"]
#CMD ["./fio_job_template.sh"]
