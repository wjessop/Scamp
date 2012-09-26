class Scamp
  class Adapter
    attr_accessor :bot

    def initialize(bot, opts={})
      @bot = bot
      @opts = opts
    end

    def matches_required_format?(msg)
      return true if msg.nil?
      return true unless bot.required_format
      if bot.required_format.is_a? String
        msg.index(bot.required_format) == 0
      elsif bot.required_format.is_a? Regexp
        msg.match bot.required_format
      else
        bot.logger.error "You passed a :required_format that isn't a string or regexp, dont't know how to match it!"
      end
    end

    def strip_prefix(msg)
      # We only strip required prefxes if they are strings, and strip_prefix is set
      return msg unless bot.required_format.is_a?(String) && bot.strip_prefix
      msg.sub(bot.required_format, '').strip unless msg.nil?
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
