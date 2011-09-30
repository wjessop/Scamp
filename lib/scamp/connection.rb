class Scamp
  module Connection
    private
    
    def connect(api_key, room_list, &blk)
      EventMachine.run do
        
        # Check for rooms to join, and join them
        EventMachine::add_periodic_timer(5) do
          while id = @rooms_to_join.pop
            join_and_stream(id)
          end
        end
        
        populate_room_list do
          logger.debug "Adding #{room_list.join ', '} to list of rooms to join"
          @rooms_to_join = room_list.map{|c| room_id(c) }

          # Call a post connection block
          if block_given?
            yield
          end
        end
        
        # populate bot data separately, in case we are ignoring ourselves
        fetch_data_for('me')
        
      end
    end
      
  end
end
