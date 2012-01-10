$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'scamp'
require 'scamp/adapter'
require 'scamp/message'

class TestAdapter < Scamp::Adapter
  class Context
    attr_reader :adapter, :message

    def initialize adapter, msg
      @adapter = adapter
      @message = msg
    end

    def say msg
      puts msg
    end
  end

  def connect!
    EventMachine::PeriodicTimer.new(@opts[:delay]) do
      msg = Scamp::Message.new(self, :body => "ping")
      context = TestAdapter::Context.new self, msg
      push [context, msg]
    end
  end
end

Scamp.new do |bot|
  bot.adapter :test, TestAdapter, :delay => 1
  bot.adapter :another, TestAdapter, :delay => 5

  bot.match /^ping/, :on => [:test] do |channel, msg|
    channel.say "You Said: #{msg.body}"
  end

  bot.match /^ping/, :on => [:another] do |channel, msg|
    channel.say "This is coming from another channel!"
  end
end
