class Scamp
  module Connection
    private
    
    def connect(api_key, channel_list)
      EventMachine.run do
        
        # Check for channels to join, and join them
        EventMachine::add_periodic_timer(5) do
          while id = @channels_to_join.pop
            join_and_stream(id)
          end
        end
        
        populate_channel_list do
          logger.debug "Adding #{channel_list.join ', '} to list of channels to join"
          @channels_to_join = channel_list.map{|c| channel_id(c) }
        end
        
      end
    end
      
  end
end
