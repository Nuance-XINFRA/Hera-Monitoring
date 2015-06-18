#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'mail'
require 'timeout'
require 'json'
require 'base64'

module ::Mail
  class Exim < Sendmail
    def self.call(path, arguments, _destinations, encoded_message)
      popen "#{path} #{arguments}" do |io|
        io.puts encoded_message.to_lf
        io.flush
      end
    end
  end
end

class DashboardReporter < Sensu::Handler

  option :json_config,
    description: 'Config Name',
    short: '-j JsonConfig',
    long: '--json_config JsonConfig',
    default: 'mailer',
    required: false

  def handle
    json_config = settings[config[:json_config]]

    delivery_method = json_config['delivery_method'] || 'smtp'
    smtp_address = json_config['smtp_address'] || 'localhost'
    smtp_port = json_config['smtp_port'] || '25'
    smtp_domain = json_config['smtp_domain'] || 'localhost.localdomain'

    smtp_username = json_config['smtp_username'] || nil
    smtp_password = json_config['smtp_password'] || nil
    smtp_authentication = json_config['smtp_authentication'] || :plain
    smtp_enable_starttls_auto = json_config['smtp_enable_starttls_auto'] == 'false' ? false : true

    command = "#{@event['check']['command']}".gsub(/(-p|-P|--password)\s*\S+/, '\1 <password redacted>')
    playbook = "Playbook:  #{@event['check']['playbook']}" if @event['check']['playbook']

    screenshots = parse_output(@event['check']['output'])

    Mail.defaults do
      delivery_options = {
        address: smtp_address,
        port: smtp_port,
        domain: smtp_domain,
        openssl_verify_mode: 'none',
        enable_starttls_auto: smtp_enable_starttls_auto
      }

      unless smtp_username.nil?
        auth_options = {
          user_name: smtp_username,
          password: smtp_password,
          authentication: smtp_authentication
        }
        delivery_options.merge! auth_options
      end

      delivery_method delivery_method.intern, delivery_options
    end

    begin
      mail = build_mail json_config, screenshots
      timeout 10 do
        mail.deliver
        puts "mail -- report #{short_name} sent"
      end
    rescue Timeout::Error
      puts 'mail -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
  end

  private

  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def build_mail_to_list json_config
    mail_to = @event['client']['mail_to'] || json_config['report_to']
    if json_config.key?('subscriptions')
      @event['check']['subscribers'].each do |sub|
        if json_config['subscriptions'].key?(sub)
          mail_to << ", #{json_config['subscriptions'][sub]['mail_to']}"
        end
      end
    end
    mail_to
  end

  def parse_output output
    data = output.match(/Sensu\:\:Plugin\:\:CLI\:\s\[\"(.*)\"\]/)[1].gsub("\\", "")
    JSON.parse(data)
  end

  def build_mail json_config, screenshots
    mail_to = build_mail_to_list json_config
    mail_from = json_config['mail_from']
    reply_to = json_config['reply_to'] || mail_from
    subject = "#{short_name}"

    Mail.new do
      from mail_from
      to mail_to
      reply_to reply_to
      subject subject
      body = "<html><head><style>
      figure {
        position: relative;
        margin: 1.5em 0;
        border-top: 1px dotted #0098d8;
        border-bottom: 1px dotted #0098d8;
        text-align: center;
      }
      figcaption {
        clear: left;
        margin: .75em 0;
        text-align: center;
        font-style: italic;
        line-height: 1.5em;
      }
      </style></head><body>"
      screenshots.each do |screenshot|
        file_name = (Time.now.to_f * 1000.0).to_i.to_s + ".png"
        attachments[file_name] = Base64.decode64(screenshot['capture'])
        attachment = attachments[file_name]
        body << "<figure><img alt='#{screenshot['url']}' src='cid:#{attachment.cid}' />"
        body << "<figcaption>#{screenshot['url']} (#{screenshot['date']})</figcaption></figure>"
      end
      body body + "</body></html>"
      parts.last.content_type "text/html"
    end
  end

end
