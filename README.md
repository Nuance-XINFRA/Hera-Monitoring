# Héra Monitoring

*Héra Monitoring* is a ready to use / easy to use Monitoring stack running with [Docker](https://www.docker.com/), composed of [Logstash](http://logstash.net/)/[Kibana](http://www.elasticsearch.org/overview/kibana/) for log management, [Graphite](http://graphite.wikidot.com/)/[Grafana](http://grafana.org/) as scalable real-time graphing system and [Sensu](http://sensuapp.org/)/[Uchiwa](https://github.com/sensu/uchiwa) as monitoring framework.


![Architecture](https://raw.githubusercontent.com/Nuance-Mobility/Hera-Monitoring/master/Architecture.png)


## Getting Started

In order to build/run the Héra Monitoring stack, you'll need to have Docker and Fig installed on your machine.
Please look at the [Docker Installation Guide](https://docs.docker.com/installation/mac/) and the [Fig Installation Guide](http://www.fig.sh/install.html) if you don't have them installed.

To Run the stack using images from the official Docker Registry:

	cd ./run
	fig -p heramonitoring -f data-containers.yml up -d
	fig -p heramonitoring up -d


If you want to change the Dockerfiles, make your own builds and run your own images:

	cd ./build
	fig -p heramonitoring up -d

##Monitoring Data

All your data (dashboards, metrics and logs) are stored inside [Data Volume Containers](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container). When you remove them, you are also removing all the data contained inside. That's why, you have two different *Fig* files to run the stack using images from the official Docker Registry:
* One to create, recreate, start, stop remove containers running the services
* One to create, recreate, start, stop remove containers containing your important data

Be careful to always use the one you really want to avoid data loss.

## Configuration

### Elasticsearch

You'll find several configuration files in the /run/elasticsearch folder:
* *elasticsearch.yml*: This is the Elasticsearch Configuration file. The one we provide just add the support for HTTP Cross Domain requests.
* *curator.json*: This is a configuration file to configure your data retention in ElasticSearch. The one we provide specify a retention of 14 days for the Logstash data.
* *logging.yml*: The logging configuration file. The one we provide is the default one provided by ElasticSearch.

### Grafana

You'll find only one configuration file in the /run/grafana folder:
* *config.js*: This is the Grafana Configuration file. The one we provide specify the correct host/port for the other services Grafana needs to communicate with.

### Graphite

You'll find several configuration files in the /run/graphite folder:
* *carbon.conf*: This is the Carbon (the backend use by Graphite) Configuration file. The one we provide should be good for most of the cases but feel free to customize it.
* *storage-schemas.conf*: Another Carbon Configuration file. This one is useful to configure the retentions of your Graphite data.

### Kibana

You'll find only one configuration file in the /run/kibana folder:
* *config.js.*: This is the Kibana Configuration file. The one we provide specify the correct host/port for the other services Kibana needs to communicate with.

### Logstash

### Monitoring Proxy (nginx)

### Sensu

### Sensu Client

### Uchiwa

## Credits
* Authors & Maintainers: [Brice Argenson](https://github.com/bargenson/), [Sylvain Boily](https://github.com/djsly/)
* Contributors: You? :-)