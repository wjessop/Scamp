class Scamp
  class Matcher
    attr_accessor :on, :conditions, :trigger, :action, :bot, :required_prefix

    def initialize(bot, params = {})
      params ||= {}
      params[:conditions] ||= {}
      params[:on] ||= []
      params.each { |k,v| send("#{k}=", v) }
      @bot = bot
    end

    def attempt(channel, msg)
      if listening?(channel) && msg.matches?(trigger) && msg.valid?(conditions)
        run(msg)
        return true
      end
      return false
    end

    def run(msg)
      action.call(msg)
    end

    def listening?(channel)
      on.empty? || on.include?(channel)
    end
  end
end
