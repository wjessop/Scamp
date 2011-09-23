class Scamp
  module Rooms
    # TextMessage (regular chat message),
    # PasteMessage (pre-formatted message, rendered in a fixed-width font),
    # SoundMessage (plays a sound as determined by the message, which can be either “rimshot”, “crickets”, or “trombone”),
    # TweetMessage (a Twitter status URL to be fetched and inserted into the chat)
    
    def paste(text, room)
    end
    
    def upload
    end
    
    def join(room_id)
      logger.info "Joining room #{room_id}"
      url = "https://#{subdomain}.campfirenow.com/room/#{room_id}/join.json"
      http = EventMachine::HttpRequest.new(url).post :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X']}
      
      http.errback { logger.error "Error joining room: #{room_id}" }
      http.callback {
        yield if block_given?
      }
    end

    def room_id(room_id_or_name)
      if room_id_or_name.is_a? Integer
        return room_id_or_name
      else
        return room_id_from_room_name(room_id_or_name)
      end
    end
    
    def room_name_for(room_id)
      data = room_cache_data(room_id)
      return data["name"] if data
      room_id.to_s
    end
    
    private
    
    def room_cache_data(room_id)
      return room_cache[room_id] if room_cache.has_key? room_id
      fetch_room_data(room_id)
      return false
    end
    
    def populate_room_list
      url = "https://#{subdomain}.campfirenow.com/rooms.json"
      http = EventMachine::HttpRequest.new(url).get :head => {'authorization' => [api_key, 'X']}
      http.errback { logger.error "Error populating the room list: #{http.status.inspect}" }
      http.callback {
        new_rooms = {}
        Yajl::Parser.parse(http.response)['rooms'].each do |c|
          new_rooms[c["name"]] = c
        end
        # No idea why using the "rooms" accessor here doesn't
        # work but accessing the ivar directly does. There's
        # Probably a bug.
        @rooms = new_rooms # replace existing room list
        yield if block_given?
      }
    end

    def fetch_room_data(room_id)
      logger.debug "Fetching room data for #{room_id}"
      url = "https://#{subdomain}.campfirenow.com/room/#{room_id}.json"
      http = EventMachine::HttpRequest.new(url).get :head => {'authorization' => [api_key, 'X']}
      http.errback { logger.error "Couldn't get data for room #{room_id} at url #{url}" }
      http.callback {
        logger.debug "Fetched room data for #{room_id}"
        room = Yajl::Parser.parse(http.response)['room']
        room_cache[room["id"]] = room

        room['users'].each do |u|
          update_user_cache_with(u["id"], u)
        end
      }
    end
    
    def join_and_stream(id)
      join(id) do
        logger.info "Joined room #{id} successfully"
        fetch_room_data(id)
        stream(id)
      end
    end
    
    def stream(room_id)
      json_parser = Yajl::Parser.new :symbolize_keys => true
      json_parser.on_parse_complete = method(:process_message)
      
      url = "https://streaming.campfirenow.com/room/#{room_id}/live.json"
      # Timeout per https://github.com/igrigorik/em-http-request/wiki/Redirects-and-Timeouts
      http = EventMachine::HttpRequest.new(url, :connect_timeout => 20, :inactivity_timeout => 0).get :head => {'authorization' => [api_key, 'X']}
      http.errback { logger.error "Couldn't stream room #{room_id} at url #{url}" }
      http.callback { logger.info "Disconnected from #{url}"; rooms_to_join << room_id}
      http.stream {|chunk| json_parser << chunk }
    end

    def room_id_from_room_name(room_name)
      logger.debug "Looking for room id for #{room_name}"
      rooms[room_name]["id"]
    end
  end
end
