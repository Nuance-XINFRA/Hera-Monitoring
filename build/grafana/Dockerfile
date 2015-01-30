FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Grafana
RUN 		curl -O -L http://grafanarel.s3.amazonaws.com/grafana-1.9.0-rc1.tar.gz && \
			tar xf grafana-1.9.0-rc1.tar.gz && \
			mv grafana-1.9.0-rc1 /usr/share/grafana

# Install httpd
RUN			apt-get install -y apache2 apache2-mpm-worker libapache2-mod-wsgi && \
			rm -f /etc/apache2/sites-enabled/000-default.conf && \
			echo "\nDocumentRoot /usr/share/grafana\n" >> /etc/apache2/apache2.conf

VOLUME 		/config

EXPOSE		80

COPY 		supervisor 	/etc/supervisor/conf.d