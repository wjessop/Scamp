class Scamp
  module Adapter
    def initialize(bot, opts={})
      @bot = bot
      @opts = opts
    end

    def subscribe &block
      channel.subscribe &block
    end

    def push(msg)
      channel.push msg
    end
    alias_method :<<, :push

    private
      def channel
        @channel ||= EM::Channel.new
      end
  end
end
