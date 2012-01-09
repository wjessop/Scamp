$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'scamp'
require 'scamp/adapter'
require 'scamp/message'

class TestAdapter
  include Scamp::Adapter

  def connect!
    EventMachine::PeriodicTimer.new(@opts[:delay]) do
      self << Scamp::Message.new(self, {:body => "ping", :room => "test-room"})
    end
  end
end

Scamp.new do |bot|
  bot.adapter :test, TestAdapter, :delay => 1
  bot.adapter :another, TestAdapter, :delay => 5

  bot.match /^ping/, :on => [:test] do |msg|
    puts "You Said: #{msg.body} and it came from #{msg.room}"
  end

  bot.match /^ping/, :on => [:another] do |msg|
    puts "This is coming from another channel!"
  end
end
