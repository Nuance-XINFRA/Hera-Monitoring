#! /usr/bin/env ruby
#
# Check Graphite Thresholds
# ===
#
# This is a Sensu plugin to check Graphite Thresholds.
#
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'sensu-plugin/utils'
require 'json'
require 'open-uri'
require 'openssl'
require 'cgi'

class CheckGraphiteThresholds < Sensu::Plugin::Check::CLI

    include Sensu::Plugin::Utils

    COMPARISON_FUNCTIONS = {
        :greaterThan => lambda { |a, b| a > b },
        :lowerThan =>  lambda { |a, b| a < b }
    }

    option :help,
    :description => 'Show this message',
    :short => '-h',
    :long => '--help'

    option :services,
    :short => '-c service1,service2,serviceN',
    :required => true

    def run
        if config[:help]
            puts opt_parser if config[:help]
            exit
        end

        unless settings['graphite_url']
            puts "Graphite configuration is missing."
            exit
        end

        services = parse_services_argument config[:services]
        services_thresholds = services.map { |service| settings['thresholds'][service] }

        results = services_thresholds.map { |service_thresholds|
            check_service_thresholds service_thresholds
        }.flatten.compact.sort { |a, b|  a[:severity] <=> b[:severity] }

        unless results.empty?
            global_severity = nil
            if results.any? { |result| result[:severity].eql?(:critical) }
                global_severity = :critical
            else
                global_severity = :warning
            end
            global_message = "#{results.length} Alerts: \n #{results.map { |result| "- #{result[:message]}" }.join(" \n ")}"
            send(global_severity, global_message)
        else
            ok("Everything is okay")
        end
    end

    private 

    def parse_services_argument services_arg
        (services_arg && services_arg.split(',')) || []
    end

    def check_service_thresholds service_thresholds
        service_thresholds.map { |threshold|
            check_threshold threshold
        }.flatten.compact
    end

    def check_threshold threshold
        graphite_values = retrieve_graphite_values threshold['target']
        graphite_values.map { |graphite_value|
            datapoint = graphite_value[:datapoint]
            severity = check_datapoint_threshold datapoint, threshold
            { 
                :severity => severity, 
                :message => "#{severity.upcase}: '#{threshold['name']}' has reached #{severity} threshold (value=#{datapoint}, target=#{graphite_value[:target]})"
            } if severity
        }.compact
    end

    def check_datapoint_threshold datapoint, threshold
        if check_datapoint_threshold_by_severity datapoint, threshold, 'critical'
            :critical
        elsif check_datapoint_threshold_by_severity datapoint, threshold, 'warning'
            :warning
        end
    end

    def check_datapoint_threshold_by_severity datapoint, threshold, severity
        if threshold[severity]
            threshold[severity].each do |key, value|
                return true if COMPARISON_FUNCTIONS[key.to_sym][datapoint, value]
            end
        end
        false
    end

    def retrieve_graphite_values target
        begin
            url = "#{settings['graphite_url']}/render?format=json&target=#{CGI::escape(target)}&from=-5mins"
            raw_data = open(url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }).gets
            if raw_data == '[]'
                unknown 'Empty data received from Graphite - metric probably doesn\'t exists.'
            else
                json_data = JSON.parse(raw_data)
                json_data.map { |raw|
                    raw['datapoints'].delete_if { |v| v.first.nil? }
                    next if raw['datapoints'].empty?
                    { 
                        :target => raw['target'], 
                        :datapoint => raw['datapoints'].map(&:first).first, 
                        :start => raw['datapoints'].first.last, 
                        :end => raw['datapoints'].last.last
                    }
                }.compact
            end
        rescue OpenURI::HTTPError => e
            unknown 'Failed to connect to graphite server'
        end
    end

    def build_url_opts
        url_opts = {} 
        if config[:no_ssl_verify]
            url_opts[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE
        end
        url_opts
    end

end