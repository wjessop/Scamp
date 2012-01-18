class Scamp
  class Adapter
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

    def connect!
      raise NotImplementedError, "connect! must be implemented"
    end

    private
      def channel
        @channel ||= EM::Channel.new
      end
  end
end
