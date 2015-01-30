# Héra Monitoring

*Héra Monitoring* is a ready to use / easy to use Monitoring stack running with [Docker](https://www.docker.com/), composed of [Logstash](http://logstash.net/)/[Kibana](http://www.elasticsearch.org/overview/kibana/) for log management, [Graphite](http://graphite.wikidot.com/)/[Grafana](http://grafana.org/) as scalable real-time graphing system and [Sensu](http://sensuapp.org/)/[Uchiwa](https://github.com/sensu/uchiwa) as monitoring framework.

## Getting Started

In order to build/run the Héra Monitoring stack, you'll need to have Docker and Fig installed on your machine.
Please look at the [Docker Installation Guide](https://docs.docker.com/installation/mac/) and the [Fig Installation Guide](http://www.fig.sh/install.html) if you don't have them installed.

To Run the stack using images from the official Docker Registry:

	cd ./run
	fig -p heramonitoring -f data-containers.yml up -d
	fig -p heramonitoring up -d


If you want to change the Dockerfile, make your own builds and run your own images:

	cd ./build
	fig -p heramonitoring up -d

##Monitoring Data

All your data (dashboards, metrics and logs) are stored inside [Data Volume Containers](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container). When you remove them, you are also removing all the data contained inside. That's why, you have two different Fig files to Run the stack using images from the official Docker Registry:
* One to create, recreate, start, stop remove containers running the services
* One to create, recreate, start, stop remove containers containing your important data
Be careful to always use the one you really want to avoid data loss.

## Credits
* Author & Maintainers: [Brice Argenson][bargenson], [Sylvain Boily][djsly]
* Contributors: You? :-)