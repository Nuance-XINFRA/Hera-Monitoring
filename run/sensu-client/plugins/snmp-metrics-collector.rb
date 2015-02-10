#!/usr/bin/env ruby
#
# SNMP Metrics Collector
# ===
#
# This is a Sensu plugin to collect SNMP metrics on a multi-hosts / multi-services environment.
# You'll need two configuration files to use it:
# - environment.json
# - snmp-conf.json
#
# Usage example:
# - ./snmp-metrics-collector
# - ./snmp-metrics-collector -c service1,service2,serviceN
# - ./snmp-metrics-collector -P 7161 -C myCommunity
#
# Requires SNMP gem
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'snmp'
require 'json'

class SnmpMetricsCollector < Sensu::Plugin::Metric::CLI::Graphite

    SENSU_FOLDER = "/etc/sensu"
    PLUGIN_CONFIG_FOLDER = "#{SENSU_FOLDER}/plugins"
    ENVIRONMENT_FILE = "#{PLUGIN_CONFIG_FOLDER}/environment.json"
    SNMP_CONF_FILE = "#{PLUGIN_CONFIG_FOLDER}/snmp-conf.json"

    MIB_DIR = "#{SENSU_FOLDER}/mib"

    option :community,
    :short => '-C snmp community',
    :boolean => true,
    :default => "public"

    option :port,
    :short => '-P port',
    :boolean => true,
    :default => "161"

    option :services,
    :short => '-c service1,service2,serviceN',
    :boolean => false

    def run
        environment = parse_environment_file
        snmp_conf = parse_snmp_conf_file
        requested_services = parse_services_argument
        process_collection environment, snmp_conf, requested_services
        ok
    end

    private

    def parse_environment_file
        parse_json_file ENVIRONMENT_FILE
    end

    def parse_snmp_conf_file
        parse_json_file SNMP_CONF_FILE
    end

    def parse_json_file file_path
        File.open(file_path, "r") do |file|
            JSON.load(file)
        end
    end

    def parse_services_argument
        (config[:services] && config[:services].split(',')) || []
    end

    def process_collection environment, snmp_conf, requested_services, parent_prefix = nil
        mib_modules = snmp_conf['mib_modules']
        prefix = (parent_prefix && "#{parent_prefix}.#{environment['prefix']}") || "#{environment['prefix']}"
        if environment['services']
            services = filter_by_requested_services environment['services'], requested_services
            services.each do |service|
                snmp_service_conf = snmp_conf['services'].select { |entry| entry['type'] == service['type'] }.first
                process_service_collection service, snmp_service_conf, mib_modules, prefix
            end
        end
        if environment['subgroups']
            environment['subgroups'].each do |subgroup|
                process_collection(subgroup, snmp_conf, requested_services, prefix)
            end
        end
    end

    def filter_by_requested_services services, requested_services
        unless requested_services.empty?
            services.reject { |service| !requested_services.include? service['type'] }
        else
            services
        end
    end

    def process_service_collection service, snmp_service_conf, mib_modules, prefix
        if snmp_service_conf
            puts "Processing #{service['type']} service(s)..."
            service['devices'].each do |device|
                puts "Collecting metrics on #{device}..."
                send_snmp_walk_request(device, snmp_service_conf, mib_modules, prefix)
                puts "Collection complete for #{device}."
            end
            puts "#{service['type']} service(s) done."
        end
    end

    def send_snmp_walk_request device, snmp_service_conf, mib_modules, prefix
        begin
            SNMP::Manager.open(
                :host => "#{device}", :port => "#{config[:port]}", :community => "#{config[:community]}",
                :mib_dir => "#{MIB_DIR}", :mib_modules => mib_modules, :Timeout => 5
                ) do |manager|
                snmp_service_conf['oids'].each do |oid|
                    walk_success = false
                    manager.walk([oid]) do |index|
                        index.each do |vb|
                            print_graphite_entry vb, mib_modules, prefix, snmp_service_conf['type'], device
                            walk_success = true
                        end
                    end
                    unless walk_success
                        puts "Nothing returned with a SNMP walk. Trying a SNMP get..."
                        manager.get([oid]).each_varbind do |vb|
                            unless vb.value.to_s == 'noSuchInstance'
                                print_graphite_entry vb, mib_modules, prefix, snmp_service_conf['type'], device
                            else
                                puts "SNMP request failed. Impossible to retrieve #{oid}."
                            end
                        end
                    end
                end
            end
        rescue SNMP::RequestTimeout
            puts "Timeout: #{device} is not responding."
        rescue Exception => e
            puts "An unknown error occured: #{e.inspect}."
        end
    end

    def print_graphite_entry(varbind, mib_modules, prefix, service_type, device)
        name = resolve_metric_name "#{varbind.oid}", mib_modules
        output "#{prefix}.#{service_type}.#{device.gsub('.', '_')}.#{name}", varbind.value.to_f
    end

    def resolve_metric_name raw_name, mib_modules
        name = raw_name.gsub('.', '_').sub(/\_[0-9]*$/, '').sub(/::wdepe/, '')
        mib_modules.each { |mib_module| name = name.sub(/#{mib_module}/, '') }
        name
    end

end

