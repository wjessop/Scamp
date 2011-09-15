class Scamp
  class Matcher
    attr_accessor :conditions, :trigger, :action, :bot
    
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
      if trigger.is_a? String
        return true if trigger == message_text
      elsif trigger.is_a? Regexp
        return trigger.match message_text
      else
        logger.warn "Don't know what to do with #{trigger.inspect} at #{__FILE__}:#{__LINE__}"
      end
      false
    end
    
    def run(msg, match = nil)
      action_run = Action.new(bot, action, msg)
      action_run.matches = match if match
      action_run.run
    end
    
    def conditions_satisfied_by(msg)
      # logger.warn "Need to take into account nick, channel and regexps at #{__FILE__}:#{__LINE__}"
      logger.info "Checking message against #{conditions.inspect}"
      
      # nick
      # channel name
      # nick regex
      # channel regex
      
      #{"room_id":1,"created_at":"2009-12-01 23:44:40","body":"hello","id":1,"user_id":1,"type":"TextMessage"}
      
      # item will be :nick or :channel
      # cond is the regex, int or string value.
      conditions.each do |item, cond|
        logger.debug "Checking #{item} against #{cond}"
        logger.debug "msg is #{msg.inspect}"
        if cond.is_a? Integer
          # logger.debug "item is #{msg[{:channel => :room_id, :user => :user_id}[item]]}"
          return false unless msg[{:channel => :room_id, :user => :user_id}[item]] == cond
        elsif cond.is_a? String
          case item
          when :channel
            return false unless bot.channel_name_for(msg[:room_id]) == cond
          when :user
            return false unless bot.username_for(msg[:user_id]) == cond
          end
          logger.error "Don't know how to deal with a match item of #{item}, cond #{cond}"
        elsif cond.is_a? Regexp
          return false
          return false unless msg[item].match(cond)
        end
      end
      true
    end
  end
end
