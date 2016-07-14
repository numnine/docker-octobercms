FROM debian:wheezy
MAINTAINER Linh P <linhpth@gmail.com>

RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449; \
	echo deb http://dl.hhvm.com/debian wheezy main | tee /etc/apt/sources.list.d/hhvm.list; \
	apt-get update; \
	apt-get -y install --no-install-recommends mysql-client hhvm  nginx curl unzip ca-certificates; \
	/usr/share/hhvm/install_fastcgi.sh; \
	echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Install composer
RUN cd /usr/local/sbin/ && curl -sS -k https://getcomposer.org/installer | php && mv composer.phar composer

# Install OctoberCMS
RUN mkdir /webapp
COPY src/ /webapp/

WORKDIR /webapp

EXPOSE 80

ADD octobercms/php.ini /etc/hhvm/php.ini
ADD octobercms/start.sh /start.sh
ADD octobercms/nginx-default /etc/nginx/sites-enabled/default

CMD ["/bin/bash", "/start.sh"]