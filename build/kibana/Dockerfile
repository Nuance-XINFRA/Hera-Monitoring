FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Kibana
RUN 		curl -O https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz && \
			tar xvf kibana-3.1.2.tar.gz && \
			mv kibana-3.1.2 /usr/share/kibana3

# Install Nginx
RUN 		apt-get update -y && \
            apt-get install -y nginx && \
			curl -O https://gist.githubusercontent.com/thisismitch/2205786838a6a5d61f55/raw/f91e06198a7c455925f6e3099e3ea7c186d0b263/nginx.conf && \
			sed -i 's|server_name           kibana.myhost.org;|server_name           localhost;|g' nginx.conf && \
			mv nginx.conf /etc/nginx/sites-available/default && \
			sed -i 's|user www-data;|daemon off;|g' /etc/nginx/nginx.conf

VOLUME 		/config

EXPOSE 		80

COPY 		supervisor 	/etc/supervisor/conf.d