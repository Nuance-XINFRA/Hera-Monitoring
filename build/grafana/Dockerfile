FROM 				nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Grafana
RUN 				curl -O -L http://grafanarel.s3.amazonaws.com/grafana-1.9.0-rc1.tar.gz && \
						tar xf grafana-1.9.0-rc1.tar.gz && \
						mv grafana-1.9.0-rc1 /usr/share/grafana

# Install httpd
RUN					apt-get update -y && \
            apt-get install -y apache2 apache2-mpm-worker libapache2-mod-wsgi && \
						rm -f /etc/apache2/sites-enabled/000-default.conf && \
						echo "\nDocumentRoot /usr/share/grafana\n" >> /etc/apache2/apache2.conf

						
# Enable apache2 modes
RUN					a2enmod headers
RUN					a2enmod rewrite
RUN					a2enmod proxy
RUN					a2enmod proxy_http

COPY        docker-entrypoint.sh /
COPY        grafana_init_script.sh /

EXPOSE			80

ENTRYPOINT  ["/docker-entrypoint.sh"]

CMD 				["-c", "/usr/share/grafana/config.js"]
