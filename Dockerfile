FROM python:3.9-buster

MAINTAINER Mateo Boudet <mateo.boudet@inrae.fr>

# Install packages and PHP-extensions
RUN echo "deb https://apt.genouest.org/ buster main" > /etc/apt/sources.list.d/slurm_genouest.list \
 && wget -qO - https://apt.genouest.org/dists/buster/Release.gpg | sudo apt-key add - \
 && apt-get -q update \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install \
     git libslurm35 libslurmdb35 slurm-client munge \
 && rm -rf /var/lib/apt/lists/*

# Some env var for slurm only
ADD requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

ENV SLURMGID='992' \
    SLURMUID='992' \
    MUNGEGID='991' \
    MUNGEUID='991' \
    DRMAA_LIBRARY_PATH='/etc/slurm-llnl/drmaa/lib/libdrmaa.so.1'

RUN mkdir -p /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm /run/munge && \
    chown -R slurm:slurm /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm && \
    chmod 755 /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm

ADD entrypoint.sh /
ADD /scripts/ /scripts/

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
