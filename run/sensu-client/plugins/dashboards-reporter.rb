#! /usr/bin/env ruby
#
# Dashboards Reporter
# ===
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'sensu-plugin/utils'
require 'open-uri'
require 'json'
require 'nori'
require 'openssl'
require 'cgi'

class DashboardsReporter < Sensu::Plugin::CLI

  include Sensu::Plugin::Utils

  option :help,
  :description => 'Show this message',
  :short => '-h',
  :long => '--help'

  option :links,
  :short => '-l url1,url2',
  :required => true

  option :wait,
  :short => '-w waitTime',
  :required => false

  def run
    if config[:help]
      puts opt_parser if config[:help]
      exit
    end
    unless settings['screenshoter_url']
      puts "Screenshoter configuration is missing."
      exit
    end
    links = parse_links_argument
    screenshots = generate_screenshots links
    ok JSON.generate(screenshots)
  end

  private

  def parse_links_argument
    (config[:links] && config[:links].split(',')) || []
  end

  def generate_screenshots links
    url = "#{settings['screenshoter_url']}/?#{links.map { |link| "url=" + CGI::escape(link) }.join('&')}"
    url << "&waitTime=#{config[:wait]}" if config[:wait]
    puts "Sending request to #{url}"
    begin
      raw_data = open(url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }).read
      JSON.parse raw_data
    rescue OpenURI::HTTPError => e
      unknown "Failed to connect to Screenshoter server (#{url})"
    end
  end

end
