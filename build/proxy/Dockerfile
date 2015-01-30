FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

RUN 		apt-get install -y nginx && \
			sed -i 's|user www-data;|daemon off;|g' /etc/nginx/nginx.conf

VOLUME 		/etc/nginx/sites-enabled
VOLUME 		/usr/share/nginx/html			

EXPOSE 		80

COPY 		supervisor 	/etc/supervisor/conf.d