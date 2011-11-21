require 'eventmachine'
require 'em-http-request'
require 'yajl'
require "logger"

require "scamp/version"
require 'scamp/connection'
require 'scamp/rooms'
require 'scamp/users'
require 'scamp/matcher'
require 'scamp/action'
require 'scamp/messages'

class Scamp
  include Connection
  include Rooms
  include Users
  include Messages

  attr_accessor :rooms, :user_cache, :room_cache, :matchers, :api_key, :subdomain,
                :logger, :verbose, :first_match_only, :ignore_self, :required_prefix,
                :rooms_to_join

  def initialize(options = {})
    options ||= {}
    raise ArgumentError, "You must pass an API key" unless options[:api_key]
    raise ArgumentError, "You must pass a subdomain" unless options[:subdomain]

    options.each do |k,v|
      s = "#{k}="
      if respond_to?(s)
        send(s, v)
      else
        logger.warn "Scamp initialized with #{k.inspect} => #{v.inspect} but NO UNDERSTAND!"
      end
    end
    
    @rooms_to_join = []
    @rooms = {}
    @user_cache = {}
    @room_cache = {}
    @matchers ||= []
  end
  
  def behaviour &block
    instance_eval &block
  end
  
  def connect!(room_list, &blk)
    logger.info "Starting up"
    connect(api_key, room_list, &blk)
  end
  
  def command_list
    matchers.map{|m| [m.trigger, m.conditions] }
  end

  def logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.level = (verbose ? Logger::DEBUG : Logger::INFO)
    end
    @logger
  end

  def verbose
    @verbose = false if @verbose == nil
    @verbose
  end

  def first_match_only
    @first_match_only = false if @first_match_only == nil
    @first_match_only
  end

  private

  def match trigger, params={}, &block
    params ||= {}
    matchers << Matcher.new(self, {:trigger => trigger, :action => block, :conditions => params[:conditions], :required_prefix => required_prefix})
  end
  
  def process_message(msg)
    logger.debug "Received message #{msg.inspect}"
    return false if ignore_self && is_me?(msg[:user_id])
    matchers.each do |matcher|
      break if first_match_only & matcher.attempt(msg)
    end
  end
end
