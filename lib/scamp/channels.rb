class Scamp
  module Channels
    # TextMessage (regular chat message),
    # PasteMessage (pre-formatted message, rendered in a fixed-width font),
    # SoundMessage (plays a sound as determined by the message, which can be either “rimshot”, “crickets”, or “trombone”),
    # TweetMessage (a Twitter status URL to be fetched and inserted into the chat)
    
    def paste(text, channel)
    end
    
    def upload
    end
    
    def join(channel_id)
      logger.info "Joining channel #{channel_id}"
      url = "https://#{subdomain}.campfirenow.com/room/#{channel_id}/join.json"
      http = EventMachine::HttpRequest.new(url).post :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X']}
      
      http.errback { logger.error "Error joining channel: #{channel_id}" }
      http.callback {
        yield if block_given?
      }
    end

    def channel_id(channel_id_or_name)
      if channel_id_or_name.is_a? Integer
        return channel_id_or_name
      else
        return channel_id_from_channel_name(channel_id_or_name)
      end
    end
    
    def channel_name_for(channel_id)
      data = channel_cache_data(channel_id)
      return data["name"] if data
      channel_id.to_s
    end
    
    private
    
    def channel_cache_data(channel_id)
      return channel_cache[channel_id] if channel_cache.has_key? channel_id
      fetch_channel_data(channel_id)
      return false
    end
    
    def populate_channel_list
      url = "https://#{subdomain}.campfirenow.com/rooms.json"
      http = EventMachine::HttpRequest.new(url).get :head => {'authorization' => [api_key, 'X']}
      http.errback { logger.error "Error populating the channel list: #{http.status.inspect}" }
      http.callback {
        new_channels = {}
        Yajl::Parser.parse(http.response)['rooms'].each do |c|
          new_channels[c["name"]] = c
        end
        # No idea why using the "channels" accessor here doesn't
        # work but accessing the ivar directly does. There's
        # Probably a bug.
        @channels = new_channels # replace existing channel list
        yield if block_given?
      }
    end

    def fetch_channel_data(channel_id)
      logger.debug "Fetching channel data for #{channel_id}"
      url = "https://#{subdomain}.campfirenow.com/room/#{channel_id}.json"
      http = EventMachine::HttpRequest.new(url).get :head => {'authorization' => [api_key, 'X']}
      http.errback { logger.error "Couldn't get data for channel #{channel_id} at url #{url}" }
      http.callback {
        logger.debug "Fetched channel data for #{channel_id}"
        room = Yajl::Parser.parse(http.response)['room']
        channel_cache[room["id"]] = room
        room['users'].each do |u|
          update_user_cache_with(u["id"], u)
        end
      }
    end
    
    def join_and_stream(id)
      join(id) do
        logger.info "Joined channel #{id} successfully"
        fetch_channel_data(id)
        stream(id)
      end
    end
    
    def stream(channel_id)
      json_parser = Yajl::Parser.new :symbolize_keys => true
      json_parser.on_parse_complete = method(:process_message)
      
      url = "https://streaming.campfirenow.com/room/#{channel_id}/live.json"
      # Timeout per https://github.com/igrigorik/em-http-request/wiki/Redirects-and-Timeouts
      http = EventMachine::HttpRequest.new(url, :connect_timeout => 20, :inactivity_timeout => 0).get :head => {'authorization' => [api_key, 'X']}
      http.errback { logger.error "Couldn't stream channel #{channel_id} at url #{url}" }
      http.callback { logger.info "Disconnected from #{url}"; channels_to_join << channel_id}
      http.stream {|chunk| json_parser << chunk }
    end

    def channel_id_from_channel_name(channel_name)
      logger.debug "Looking for channel id for #{channel_name}"
      channels[channel_name]["id"]
    end
  end
end
