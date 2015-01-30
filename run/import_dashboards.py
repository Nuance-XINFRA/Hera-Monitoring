#!/usr/bin/env python 

import os, argparse, json, urllib2, urllib

elasticsearch_indexes = {
	"grafana": "grafana-dash",
	"kibana": "kibana-int"
}

def parse_arguments():
	parser = argparse.ArgumentParser(description='Import Kibana/Grafana Dashboards.')
	parser.add_argument('elasticsearch_url', help='Elasticsearch URL')
	parser.add_argument('dashboard_service', help='Choose between Kibana or Grafana')
	parser.add_argument('files_location', help='Path to the fodler containing the Dashboards')
	return parser.parse_args()

def read_dashboards(files_location):
	for root, dirs, files in os.walk(files_location):
		return map(lambda file: get_file_content(root + file), filter(lambda file: file.endswith(".json"), files))

def get_file_content(file):
	with open(file) as f:
		return json.load(f)

def create_dashboards(dashboards, elasticsearch_url, index):
	for dashboard in dashboards:
		create_dashboard(dashboard, elasticsearch_url, index)

def create_dashboard(dashboard, elasticsearch_url, index):
	data = {
		"user": "guest", 
		"group": "guest",
		"title": dashboard['title'],
		"dashboard": json.dumps(dashboard)
	}
	urlencoded_title = urllib.quote(dashboard['title']).translate(None, '/')
	send_put_request(elasticsearch_url, "%s/dashboard/%s" % (index, urlencoded_title), json.dumps(data))

def send_put_request(baseurl, path, data):
	opener = urllib2.build_opener(urllib2.HTTPHandler)
	request = urllib2.Request("%s/%s" % (baseurl, path), data=data)
	request.get_method = lambda: 'PUT'
	result = opener.open(request)
	print "Resource created in %s" % result.url

def main():
	args = parse_arguments()
	dashboards = read_dashboards(args.files_location)
	create_dashboards(dashboards, args.elasticsearch_url, elasticsearch_indexes[args.dashboard_service])

main()