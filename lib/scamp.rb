require 'eventmachine'
require "logger"

require "scamp/version"
require 'scamp/matcher'
require 'scamp/adapter'
require 'scamp/plugin'

class Scamp
  attr_accessor :adapters, :plugins, :matchers, :logger, :verbose, :first_match_only

  def initialize(options = {}, &block)
    options ||= {}
    options.each do |k,v|
      s = "#{k}="
      if respond_to?(s)
        send(s, v)
      else
        logger.warn "Scamp initialized with #{k.inspect} => #{v.inspect} but NO UNDERSTAND!"
      end
    end
    
    @matchers ||= []
    @adapters ||= {}
    @plugins  ||= []

    yield self
  end

  def adapter name, klass, opts={}
    adapter = klass.new self, opts
    sid = adapter.subscribe do |context, msg|
      process_message(name, context, msg)
    end
    @adapters[name] = {:adapter => adapter, :sid => sid}
  end

  def plugin klass, opts={}
    plugins << klass.new(self, opts)
  end

  def connect!
    EM.run do
      @adapters.each do |name, data|
        logger.info "Connecting to #{name} adapter"
        data[:adapter].connect!
      end
    end
  end

  def command_list
    matchers.map{|m| [m.trigger, m.conditions] }
  end

  def logger
    @logger ||= Logger.new(STDOUT)
    @logger.level = (verbose ? Logger::DEBUG : Logger::INFO)
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

  def match trigger, params={}, &block
    matchers << Matcher.new(self, {:trigger => trigger, :action => block, :on => params[:on], :conditions => params[:conditions]})
  end

  def process_message(channel, context, msg)
    matchers.each do |matcher|
      break if first_match_only & matcher.attempt(channel, context, msg)
    end
  end
end
