# Héra Monitoring

*Héra Monitoring* is a ready to use / easy to use Monitoring stack running with [Docker](https://www.docker.com/), composed of [Logstash](http://logstash.net/)/[Kibana](http://www.elasticsearch.org/overview/kibana/) for log management, [Graphite](http://graphite.wikidot.com/)/[Grafana](http://grafana.org/) as scalable real-time graphing system and [Sensu](http://sensuapp.org/)/[Uchiwa](https://github.com/sensu/uchiwa) as monitoring framework.


![Architecture](https://raw.githubusercontent.com/Nuance-Mobility/Hera-Monitoring/master/Architecture.png)


## Getting Started

In order to build/run the Héra Monitoring stack, you'll need to have Docker and Docker Compose installed on your machine.
Please look at the [Docker Installation Guide](https://docs.docker.com/installation/) and the [Docker Compose Installation Guide](https://docs.docker.com/compose/install/) if you don't have them installed.

To Run the stack using the images from the official Docker Registry:

	cd ./run
	docker-compose -p heramonitoring -f data-containers.yml up -d
	docker-compose -p heramonitoring up -d


##Monitoring Data

All your data (dashboards, metrics and logs) are stored inside [Data Volume Containers](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container). When you remove them, you are also removing all the data contained inside. That's why, you have two different *Fig* files to run the stack:
* One to create, recreate, start, stop remove containers running the services
* One to create, recreate, start, stop remove containers containing your important data

Be careful to always use the one you really want to avoid data loss.

## Configuration

You'll find several configuration files in /run/*service_name* folders:

### Elasticsearch Curator

* *curator.json*: This is a configuration file to configure your data retention in ElasticSearch. The one we provide specify a retention of 14 days for the Logstash data.

### Grafana

* *config.js*: This is the Grafana configuration file. The one we provide specify the correct host/port for the other services Grafana needs to communicate with.
* Refer to the [grafana](https://github.com/Nuance-Mobility/Hera-Monitoring/tree/master/build/grafana) image in build folder for details on available custom configurations controllable at container startup time. 

### Graphite-Web

* *local_settings.py*: This is the graphite-web configuration file. The one we provide should be good for most of the cases but feel free to customize it. 
* Refer to the [graphite-web](https://github.com/Nuance-Mobility/Hera-Monitoring/tree/master/build/graphite-web) image in build folder for details on available custom configurations controllable at container startup time. 

### Carbon

* *cache/carbon.conf*: This is the Carbon-Cache (the backend use by Graphite to store data in Whisper files) Configuration file. The one we provide should be good for most of the cases but feel free to customize it.
* *cache/storage-schemas.conf*: Another Carbon Configuration file. This one is useful to configure the retentions of your Graphite data.
* *relay/carbon.conf*: This is the Carbon-Relay (the backend use by Graphite to distribute data writing across multiple Carbon-Cache) Configuration file. The one we provide should be good for most of the cases but feel free to customize it.
* Refer to the [carbon](https://github.com/Nuance-Mobility/Hera-Monitoring/tree/master/build/carbon) image in build folder for details on available custom configurations controllable at container startup time. 

### Logstash

* The *config* folder: This is where you have to put your Logstash rules. The ones we provide, include SNMP trap and Lumberjack inputs, filter rules for SNMP traps and Log4j logs and finally, an output definition to Elasticsearch.
* The *ssl* folder: This is where you'll find the RSA keys used for Lumberjack communications. Feel free to use yours.

### Monitoring Proxy (Nginx)

* The Nginx *sites* configurations: The default configuration we provide, configure Nginx as a proxy using SSL for Kibana, Grafana, Uchiwa, Elasticsearch and Graphite.
* The *html* folder: By default, Nginx is configured to render the content of that folder as a welcome page. You can customize it for your organization if you need. The welcome page we provide, allows you to go on one dashboard or another in one click.
* The *ssl* folder: This is where you'll find the certificate and the private key used for HTTPS. Feel free to use yours.

### Sensu

### Sensu Client

* The *config* folder: This is where you have your sensu client configuration.
* The *plugins* folder: This is where you have to put your sensu plugins. Currently, we provide two: one to trigger alarms based on configurable thresholds on Graphite targets and another to collect SNMP metrics on a multi-hosts / multi-services environment.

### Uchiwa

* *config.js*: This is the Uchiwa configuration file.

## Credits
* Authors & Maintainers: [Brice Argenson](https://github.com/bargenson/), [Sylvain Boily](https://github.com/djsly/)
* Contributors: You? :-)