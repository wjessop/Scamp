class Scamp
  class Matcher
    attr_accessor :on, :conditions, :trigger, :action, :bot, :required_prefix

    def initialize(bot, params = {})
      params[:conditions] ||= {}
      params[:on] ||= bot.adapters.keys
      raise ArgumentError, "matcher must have a trigger" unless params[:trigger]
      raise ArgumentError, "matcher must have a action" unless params[:action]
      params.each { |k,v| send("#{k}=", v) }
      @bot = bot
    end

    def attempt(channel, context, msg)
      if listening?(channel) && msg.matches?(trigger) && msg.valid?(conditions)
        bot.logger.debug "Message '#{msg}' matched on channel '#{channel}' with conditions #{conditions}, running action"
        run_action(context, msg)
        return true
      end
      return false
    end

    def run_action(context, msg)
      action.call(context, msg)
    end

    def listening?(channel)
      on.include?(channel)
    end
  end
end
