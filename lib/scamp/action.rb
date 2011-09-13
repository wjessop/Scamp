#
# Actions are run in the context of a Scamp::Action.
# This allows us to make channel, nick etc. methods
# available on a per-message basis
#

# {:room_id=>401839, :created_at=>"2011/09/10 00:23:19 +0000", :body=>"something", :id=>408089344, :user_id=>774016, :type=>"TextMessage"}

class Scamp
  class Action
    
    attr :matches, :bot
    
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
      end
    end
    
    def channel
      puts "Need the real channel name at #{__FILE__}:#{__LINE__}"
      @message[:room_id]
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
    
    def say(msg, channel_id_or_name = channel)
      bot.say(msg, channel_id_or_name)
    end
  end
end