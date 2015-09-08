FROM        nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Graphite Web
RUN         apt-get update -y && \
            apt-get install -y python-pip && pip install django==1.6 && \
            apt-get install -y graphite-web apache2 apache2-mpm-worker libapache2-mod-wsgi && \
            graphite-manage syncdb --noinput && \
            chown -R _graphite:_graphite /var/lib/graphite

# Configure httpd
RUN 		    rm -f /etc/apache2/sites-enabled/000-default.conf && \
            cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-enabled/graphite.conf && \
            echo "\nHeader set Access-Control-Allow-Origin \"*\"\n" >> /etc/apache2/apache2.conf && \
            echo "Header set Access-Control-Allow-Methods \"GET, OPTIONS\"\n" >> /etc/apache2/apache2.conf && \
            echo "Header set Access-Control-Allow-Headers \"origin, authorization, accept\"\n" >> /etc/apache2/apache2.conf && \
            sed -i s/request.raw_post_data/request.body/g /usr/lib/python2.7/dist-packages/graphite/events/views.py && \
            a2enmod headers

COPY        docker-entrypoint.sh /
COPY		graphite_web_init_script.sh /

VOLUME      /var/lib/graphite/whisper
EXPOSE 		  80

ENTRYPOINT  ["/docker-entrypoint.sh"]
CMD         ["graphiteweb"]
