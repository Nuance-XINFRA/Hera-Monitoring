#!/usr/bin/env python

import json, subprocess, socket

CONFIGURATION_FILE = "/config/curator.json"

def parse_configuration_file():
	with open(CONFIGURATION_FILE) as f:
		return json.load(f)

def exec_curator(config):
	for retention in config['retentions']:
		host = retention['host']
		prefix = retention['prefix']
		days = retention['days']
		print "Calling '/usr/local/bin/curator --host %s delete indices --prefix %s --older-than %d --time-unit days --timestring \'%%Y.%%m.%%d\''" % (host, prefix, days)
		print subprocess.check_output(["/usr/local/bin/curator", "--host", host, "delete", "indices", "--prefix", prefix, "--older-than", str(days), "--time-unit", "days", "--timestring", "'%Y.%m.%d'"])
def main():
	config = parse_configuration_file()
	exec_curator(config)

main()