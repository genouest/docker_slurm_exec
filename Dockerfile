FROM python:3.9-buster

MAINTAINER Mateo Boudet <mateo.boudet@inrae.fr>

ADD apt_genouest_priority /etc/apt/preferences.d/apt_genouest_priority

# Install packages and PHP-extensions
RUN echo "deb [trusted=yes] https://apt.genouest.org/ buster main" > /etc/apt/sources.list.d/slurm_genouest.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-key 64D3DCC02B3AC23A8D96059FC41FF1AADA6E6518  \
 && apt-get -q update \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install \
     git libslurm37 slurm-client munge locales locales-all \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
RUN sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

# Some env var for slurm only
ADD requirements.txt /tmp/requirements.txt

RUN pip install -U pip setuptools nose build && \
    pip install -r /tmp/requirements.txt

ENV SLURMGID='992' \
    SLURMUID='992' \
    MUNGEGID='991' \
    MUNGEUID='991' \
    DRMAA_LIBRARY_PATH='/etc/slurm/drmaa/lib/libdrmaa.so.1'

RUN mkdir -p /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm /run/munge && \
    chown -R slurm:slurm /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm && \
    chmod 755 /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm

ADD entrypoint.sh /
ADD /scripts/ /scripts/

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
