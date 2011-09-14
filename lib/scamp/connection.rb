class Scamp
  module Connection
    private
    
    def connect(api_key, channels_to_join)
      EventMachine.run do
        # Ideally populate_channel_list would block, but I can't see an easy way to do this, so a hacky callback it is.
        populate_channel_list do
          channels_to_join.map{|c| channel_id(c) }.each do |id|
            logger.info "Joining channel #{id}"
            join(id) do
              logger.info "Joined channel #{id} successfully"
              fetch_channel_data(id)
              stream(id)
            end
          end
        end
      end
    end
      
  end
end
