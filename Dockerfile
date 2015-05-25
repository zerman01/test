# Pull from the ubuntu:14.04 image
FROM ubuntu:14.04

# Set the author
MAINTAINER Vu Tran <vu@vu-tran.com>

# Update cache and install base packages
RUN apt-get update && apt-get -y install \
    software-properties-common \
    python-software-properties \
    debian-archive-keyring \
    wget \
    curl \
    vim \
    aptitude \
    dialog \
    net-tools \
    mcrypt \
    build-essential \
    tcl8.5 \
    git

# Download Nginx signing key
RUN wget http://nginx.org/keys/nginx_signing.key

# Add the Nginx signing key to the keyring
RUN apt-key add nginx_signing.key

# Add to repository sources list
RUN echo 'deb http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list
RUN echo 'deb-src http://nginx.org/packages/ubuntu/ trusty nginx' >> /etc/apt/sources.list

# Update cache and install Nginx
RUN apt-get update && apt-get -y install \
    nginx \
    php5-fpm \
    php5-cli \
    php5-mysql \
    php5-curl \
    php5-mcrypt \
    php5-gd \
    php5-redis

# Turn off daemon mode
# Reference: http://stackoverflow.com/questions/18861300/how-to-run-nginx-within-docker-container-without-halting
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Backup the php.ini file
RUN cp /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.original.bak

# Configure PHP settings
RUN perl -pi -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
RUN perl -pi -e 's/allow_url_fopen = Off/allow_url_fopen = On/g' /etc/php5/fpm/php.ini
RUN perl -pi -e 's/expose_php = On/expose_php = Off/g' /etc/php5/fpm/php.ini
RUN perl -pi -e 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php5/fpm/pool.d/www.conf
RUN perl -pi -e 's/listen.group = www-data/listen.group = nginx/g' /etc/php5/fpm/pool.d/www.conf

# Make directories
RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Copy files
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy website directory
COPY index.php /var/www/html/index.php

# Mount volumes
VOLUME ["/etc/nginx/certs", "/etc/nginx/conf.d", "/var/www/html"]

# Boot up Nginx, and PHP5-FPM when container is started
CMD service php5-fpm start && nginx

# Expose port 80
EXPOSE 80
EXPOSE 443