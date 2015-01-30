#!/usr/bin/env python 

import argparse, os, subprocess, yaml

def parse_arguments():
	parser = argparse.ArgumentParser(description='Build docker images with fig and push them to a registry.')
	parser.add_argument('fig_file', help='Fig file to use to build')
	parser.add_argument('docker_registry', help='Docker registry where to push images')
	return parser.parse_args()

def build_images(fig_file):
	print "Calling 'fig -f %s build'" % fig_file
	subprocess.call(["/usr/local/bin/fig", "-f", fig_file, "build"])

def push_images_to_registry(fig_file, docker_registry):
	fig_project_name = os.path.basename(os.path.dirname(os.path.realpath(__file__))).translate(None, '- ')
	stream = file(fig_file, 'r')
	services = yaml.load(stream)
	buildable_services = {service_name: description for service_name, description in services.iteritems() if 'build' in description}
	for service_name in buildable_services:
		new_tag = tag_docker_image(fig_project_name, service_name, docker_registry)
		push_image_to_registry(new_tag)

def tag_docker_image(fig_project_name, service_name, docker_registry):
	image_name = "%s_%s" % (fig_project_name, service_name)
	tag = "%s/%s" % (docker_registry, service_name)
	print "Calling 'docker tag %s %s'" % (image_name, tag)
	subprocess.call(["/usr/bin/docker", "tag", "-f", image_name, tag])
	return tag

def push_image_to_registry(tag):
	print "Calling 'docker push %s'" % tag
	subprocess.call(["/usr/bin/docker", "push", tag])

def main():
	args = parse_arguments()
	build_images(args.fig_file)
	push_images_to_registry(args.fig_file, args.docker_registry)

main()