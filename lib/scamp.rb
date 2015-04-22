require 'eventmachine'
require "logger"

require "scamp/version"
require 'scamp/matcher'
require 'scamp/adapter'
require 'scamp/plugin'

EM.error_handler do |e|
  puts "Error raised inside the event loop: #{e.message}"
  puts e.backtrace.join("\n")
end

class Scamp
  attr_accessor :adapters, :plugins, :matchers, :logger, :verbose, :first_match_only, :required_format, :strip_prefix

  def initialize(options = {})
    options ||= {}
    options.each do |k,v|
      s = "#{k}="
      if respond_to?(s)
        send(s, v)
      else
        logger.warn "Scamp initialized with #{k.inspect} => #{v.inspect} but NO UNDERSTAND!"
      end
    end

    @strip_prefix ||= true
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
      EventMachine.error_handler do |e|
        $stderr.puts "Exception during event: #{e.message} (#{e.class})"
        $stderr.puts (e.backtrace || [])[0..10].join("\n")
      end
      @adapters.each do |name, data|
        logger.info "Connecting to #{name} adapter"
        data[:adapter].connect!
      end
    end
  end

  def logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.level = (verbose ? Logger::DEBUG : Logger::INFO)
      @logger.info "Scamp using default logger as none was provided"
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

  def match trigger, params={}, &block
    matchers << Matcher.new(self, {:trigger => trigger, :action => block, :on => params[:on], :conditions => params[:conditions]})
  end

  def process_message(channel, context, msg)
    matchers.each do |matcher|
      break if first_match_only & matcher.attempt(channel, context, msg)
    end
  end
end
