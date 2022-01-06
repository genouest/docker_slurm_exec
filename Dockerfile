FROM python:3.9-buster

MAINTAINER Mateo Boudet <mateo.boudet@inrae.fr>

WORKDIR /var/www

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7

# Install packages and PHP-extensions
RUN apt-get -q update \
&& DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install \
    file libfreetype6 libjpeg62-turbo libpng16-16 libpq-dev libx11-6 libxpm4 gnupg \
    postgresql-client wget patch git unzip ncbi-blast+ python3-pip python3-setuptools python3-wheel \
    cron libhwloc5 build-essential libssl-dev \
    zlib1g zlib1g-dev dirmngr libslurm33 libslurmdb33 slurm-client munge \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install \
     nodejs npm \
 && docker-php-ext-install mbstring pdo_pgsql zip \
 && rm -rf /var/lib/apt/lists/* \
 && a2enmod rewrite && a2enmod proxy && a2enmod proxy_http \
 && npm install -g uglify-js uglifycss \
 && ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/x86_64-linux-gnu/libssl.so.10 \
 && ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so /usr/lib/x86_64-linux-gnu/libcrypto.so.10 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Some env var for slurm only
ENV

ADD requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

ENV SLURMGID='992' \
    SLURMUID='992' \
    MUNGEGID='991' \
    MUNGEUID='991' \
    DRMAA_LIB_DIR='/etc/slurm-llnl/drmaa/lib/libdrmaa.so.1'

RUN mkdir -p /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm /run/munge && \
    chown -R slurm:slurm /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm && \
    chmod 755 /var/spool/slurmctld /var/spool/slurmd /var/run/slurm /var/log/slurm

ADD entrypoint.sh /
ADD /scripts/ /scripts/

CMD ["/entrypoint.sh"]
