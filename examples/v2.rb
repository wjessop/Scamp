$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'scamp'
require 'scamp/adapter'
require 'scamp/message'
require 'scamp/plugin'

class PingPlugin < Scamp::Plugin
  match /^ping/, :say_pong

  def say_pong channel, msg
    puts matches.inspect
    channel.say "pong"
  end
end

class CommandListPlugin < Scamp::Plugin
  match "help", :display_command_list

  def display_command_list context, msg
    max_command_length = command_list.map{|cl| cl.first.to_s }.max_by(&:size).size
    max_adapter_length = command_list.map{|cl| cl[1].join(",").to_s }.max_by(&:size).size
    command_format_string = "%#{max_command_length + 1}s"
    adapter_format_string = "%-#{max_adapter_length + 1}s"
    formatted_commands = command_list.map{|action, adapters, conds| "#{sprintf(command_format_string, action)} | #{sprintf(adapter_format_string, adapters.join(","))} | #{conds.size == 0 ? '' : conds.inspect}"}
    context.say <<-EOS
#{sprintf("%-#{max_command_length + 1}s", "Command match")} | #{sprintf(adapter_format_string, "Adapters")} | Conditions
--------------------------------------------------------------------------------
#{formatted_commands.join("\n")}
    EOS
  end
end

class TestAdapter < Scamp::Adapter
  class Context
    def say msg
      puts msg
    end
  end

  def connect!
    EventMachine::PeriodicTimer.new(@opts[:delay]) do
      msg = Scamp::Message.new(self, :body => "help")
      context = TestAdapter::Context.new
      push [context, msg]
    end
  end
end

Scamp.new do |bot|
  bot.adapter :test, TestAdapter, :delay => 1
  bot.adapter :another, TestAdapter, :delay => 5

  bot.plugin PingPlugin, :on => [:test]
  bot.plugin CommandListPlugin

  bot.connect!
end
