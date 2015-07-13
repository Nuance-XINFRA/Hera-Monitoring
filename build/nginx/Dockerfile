FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

RUN 		apt-get update -y && \
			apt-get install -y libxml2-dev libxslt-dev gcc git libssl-dev make libldap2-dev && \
			cd /tmp && \
			curl -O http://nginx.org/download/nginx-1.6.0.tar.gz && \
			tar -xf nginx-1.6.0.tar.gz && \
			rm nginx-1.6.0.tar.gz && \
			mv nginx-1.6.0 nginx_src && \
			curl -O http://colocrossing.dl.sourceforge.net/project/pcre/pcre/8.21/pcre-8.21.tar.gz && \
			tar -xzf pcre-8.21.tar.gz && \
			rm pcre-8.21.tar.gz && \
			curl -O http://garr.dl.sourceforge.net/project/libpng/zlib/1.2.5/zlib-1.2.5.tar.gz && \
			tar -xzf zlib-1.2.5.tar.gz && \
			rm zlib-1.2.5.tar.gz && \
			git clone https://github.com/kvspb/nginx-auth-ldap.git && \
			cd nginx_src && \
			./configure \
			--prefix=/etc/nginx \
			--sbin-path=/usr/sbin/nginx \
			--conf-path=/etc/nginx/nginx.conf \
			--error-log-path=/var/log/nginx/error.log \
			--http-client-body-temp-path=/var/lib/nginx/body \
			--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
			--http-log-path=/var/log/nginx/access.log \
			--http-proxy-temp-path=/var/lib/nginx/proxy \
			--http-scgi-temp-path=/var/lib/nginx/scgi \
			--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
			--lock-path=/var/lock/nginx.lock \
			--pid-path=/var/run/nginx.pid \
			--user=www-data \
			--group=www-data \
			--with-pcre=../pcre-8.21 \
			--with-zlib=../zlib-1.2.5 \
			--with-debug \
			--with-http_addition_module \
			--with-http_dav_module \
			--with-http_gzip_static_module \
			--with-http_stub_status_module \
			--with-http_ssl_module \
			--with-http_sub_module \
			--with-http_xslt_module \
			--with-ipv6 \
			--with-sha1=/usr/include/openssl \
			--with-md5=/usr/include/openssl \
			--with-mail \
			--with-mail_ssl_module \
			--add-module=../nginx-auth-ldap && \
			make && make install && \
			mkdir /var/lib/nginx/ && \
			rm -rf /tmp/*

COPY        docker-entrypoint.sh /

VOLUME 		/usr/share/nginx/html
VOLUME 		/etc/nginx/ssl			

EXPOSE 		80

ENTRYPOINT  ["/docker-entrypoint.sh"]
