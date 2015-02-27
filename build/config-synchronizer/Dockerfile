FROM        nuancemobility/ubuntu-base:14.04

RUN         apt-get install -y npm && \
            ln -s /usr/bin/nodejs /usr/bin/node && \
            git config --global user.email 'hera@nuance.com' && \
            git config --global user.name 'hera'

ADD         src     /src

RUN         cd /src && npm install

EXPOSE      8080

COPY        supervisor  /etc/supervisor/conf.d