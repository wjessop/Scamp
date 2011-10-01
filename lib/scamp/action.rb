#
# Actions are run in the context of a Scamp::Action.
# This allows us to make room, user etc. methods
# available on a per-message basis
#

# {:room_id=>401839, :created_at=>"2011/09/10 00:23:19 +0000", :body=>"something", :id=>408089344, :user_id=>774016, :type=>"TextMessage"}

class Scamp
  class Action
    
    attr_accessor :matches, :bot
    
    def initialize(bot, action, message)
      @bot = bot
      @action = action
      @message = message
    end
    
    def matches=(match)
      @matches = match[1..-1]
      match.names.each do |name|
        name_s = name.to_sym
        self.class.send :define_method, name_s do
          match[name_s]
        end
      end if match.respond_to?(:names) # 1.8 doesn't support named captures
    end
    
    def room_id
      @message[:room_id]
    end
    
    def room
      bot.room_name_for @message[:room_id]
    end
    
    def user
      bot.username_for(@message[:user_id])
    end
    
    def user_id
      @message[:user_id]
    end
    
    def message
      @message[:body]
    end
    
    def run
      self.instance_eval &@action
    end
    
    private
    
    def command_list
      bot.command_list
    end
    
    def invoke(matcher)
      bot.matchers.find_all{|m| m.trigger == matcher || (m.alias && m.alias == matcher)}.each {|m| m.run(message)}
    end
    
    def say(msg, room_id_or_name = room_id)
      bot.say(msg, room_id_or_name)
    end

    def paste(msg, room_id_or_name = room_id)
      bot.paste(msg, room_id_or_name)
    end

    def play(sound, room_id_or_name = room_id)
      bot.play(sound, room_id_or_name)
    end
  end
end
