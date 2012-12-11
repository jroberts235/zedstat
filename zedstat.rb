require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'net/http'

class ZedStats < Sensu::Plugin::Metric::CLI::Graphite

  option :host,
    :short => "-h HOST",
    :long => "--host HOST",
    :description => "HOST to check zstat output",
    :default => "localhost"

  option :port,
    :short => "-p PORT",
    :long => "--port PORT",
    :description => "Port to check zstat output",
    :default => "8080"

  option :path,
    :short => "-path PATH",
    :long => "--path PATH",
    :description => "PATH to check zstat output",
    :default => "/spiky-bangle/zstat"

  option :user,
    :short => "-user USER",
    :long => "--user USER",
    :description => "User if HTTP Basic is used",
    :default => nil

  option :password,
    :short => "-password USER",
    :long => "--password USER",
    :description => "Password if HTTP Basic is used",
    :default => nil

  option :scheme,
         :description => "Metric naming scheme, text to prepend to .$parent.$child",
         :long => "--scheme SCHEME",
         :default => "#{Socket.gethostname}"


def run
  timestamp = Time.now.to_i
  stats = Hash.new
  value = JSON.parse get_mod_status
  value.each do |k,v|
      stats[k] = v
  end
  metrics = {
    :zstat=> stats
  }
  metrics.each do |parent, children|
    children.each do |child, value|
      output [config[:scheme], parent, child].join("."), value, timestamp
    end
  end
  ok
end

def get_mod_status
    http = Net::HTTP.new(config[:host], config[:port])
    req = Net::HTTP::Get.new(config[:path])
    if (config[:user] != nil and config[:password] != nil)
      req.basic_auth config[:user], config[:password]
    end

    res = http.request(req)
    case res.code
    when "200"
        res.body
    else
        critical "Unexpected HTTP response code:#{res.code}"
    end
end
end
