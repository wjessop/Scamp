require 'eventmachine'
require 'em-http-request'
require 'yajl'
require "logger"

require "scamp/version"
require 'scamp/connection'
require 'scamp/channels'
require 'scamp/users'
require 'scamp/matcher'
require 'scamp/action'

class Scamp
  include Connection
  include Channels
  include Users
  
  attr_accessor :channels, :user_cache, :channel_cache, :matchers, :api_key, :subdomain, :logger, :verbose

  def initialize(options = {})
    options ||= {}
    raise ArgumentError, "You must pass an API key" unless options[:api_key]
    raise ArgumentError, "You must pass a subdomain" unless options[:subdomain]

    options.each do |k,v|
      s = "#{k}="
      if respond_to?(s)
        send(s, v)
      else
        logger.warn("Scamp initialized with #{k.inspect} => #{v.inspect} but NO UNDERSTAND!")
      end
    end

    @channels = {}
    @user_cache = {}
    @channel_cache = {}
    @matchers ||= []
  end
  
  def behaviour &block
    instance_eval &block
  end
  
  def connect!(channel_list)
    connect(api_key, channel_list)
  end
  
  def command_list
    matchers.map{|m| [m.trigger, m.conditions] }
  end

  def logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end
    @logger
  end

  def verbose
    @verbose = false if @verbose == nil
    @verbose
  end

  private
  
  def match trigger, params={}, &block
    params ||= {}
    matchers << Matcher.new(self, {:trigger => trigger, :action => block, :conditions => params[:conditions]})
  end
  
  def process_message(msg)
    matchers.each do |matcher|
      matcher.attempt(msg)
    end
  end
end
