class Scamp
  class Matcher
    attr_accessor :on, :conditions, :trigger, :action, :bot, :required_prefix

    def initialize(bot, params = {})
      params ||= {}
      params[:conditions] ||= {}
      params[:on] ||= bot.adapters.keys
      params.each { |k,v| send("#{k}=", v) }
      @bot = bot
    end

    def attempt(channel, context, msg)
      if listening?(channel) && msg.matches?(trigger) && msg.valid?(conditions)
        run(context, msg)
        return true
      end
      return false
    end

    def run(context, msg)
      action.call(context, msg)
    end

    def listening?(channel)
      on.include?(channel)
    end
  end
end
