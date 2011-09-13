require 'eventmachine'
require 'em-http-request'
require 'yajl'

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
  
  attr_accessor :channels, :user_cache, :channel_cache
  attr :matchers, :api_key, :subdomain

  def initialize(options = {})
    options ||= {}
    raise ArgumentError, "You must pass an API key" unless options[:api_key]
    
    @api_key = options[:api_key]
    @subdomain = options[:subdomain]
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
