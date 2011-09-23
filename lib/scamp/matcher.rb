class Scamp
  class Matcher
    attr_accessor :conditions, :trigger, :action, :bot, :required_prefix
    
    def initialize(bot, params = {})
      params ||= {}
      params[:conditions] ||= {}
      params.each { |k,v| send("#{k}=", v) }
      @bot = bot
    end
    
    def attempt(msg)
      return false unless conditions_satisfied_by(msg)
      match = triggered_by(msg[:body])
      if match
        if match.is_a? MatchData
          run(msg, match)
        else
          run(msg)
        end
        return true
      end
      false
    end
    
    private
    
    def triggered_by(message_text)
      if message_text && required_prefix 
        message_text = handle_prefix(message_text)
        return false unless message_text
      end
      if trigger.is_a? String
        return true if trigger == message_text
      elsif trigger.is_a? Regexp
        return trigger.match message_text
      else
        bot.logger.warn "Don't know what to do with #{trigger.inspect} at #{__FILE__}:#{__LINE__}"
      end
      false
    end
    
    def handle_prefix(message_text)
      return false unless message_text
      if required_prefix.is_a? String
        if required_prefix == message_text[0...required_prefix.length]
          message_text.gsub(required_prefix,'') 
        else
          false
        end
      elsif required_prefix.is_a? Regexp
        if required_prefix.match message_text
          message_text.gsub(required_prefix,'')
        else
          false
        end
      else
        false
      end
    end 
    
    def run(msg, match = nil)
      action_run = Action.new(bot, action, msg)
      action_run.matches = match if match
      action_run.run
    end
    
    def conditions_satisfied_by(msg)
      bot.logger.debug "Checking message against #{conditions.inspect}"
      
      # item will be :nick or :room
      # cond is the int or string value.
      conditions.each do |item, cond|
        bot.logger.debug "Checking #{item} against #{cond}"
        bot.logger.debug "msg is #{msg.inspect}"
        if cond.is_a? Integer
          # bot.logger.debug "item is #{msg[{:room => :room_id, :user => :user_id}[item]]}"
          return false unless msg[{:room => :room_id, :user => :user_id}[item]] == cond
        elsif cond.is_a? String
          case item
          when :room
            return false unless bot.room_name_for(msg[:room_id]) == cond
          when :user
            return false unless bot.username_for(msg[:user_id]) == cond
          end
          bot.logger.error "Don't know how to deal with a match item of #{item}, cond #{cond}"
        end
      end
      true
    end
  end
end
