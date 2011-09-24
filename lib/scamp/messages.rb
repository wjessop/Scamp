class Scamp
  module Messages

    def say(message, room_id_or_name)
      send_message(room_id_or_name, message, "Textmessage")
    end

    def play(sound, room_id_or_name)
      send_message(room_id_or_name, sound, "SoundMessage")
    end

    private

    #  curl -vvv -H 'Content-Type: application/json' -d '{"message":{"body":"Yeeeeeaaaaaahh", "type":"Textmessage"}}' -u API_KEY:X https://37s.campfirenow.com/room/293788/speak.json
    def send_message(room_id_or_name, payload, type)
      # post 'speak', :body => {:message => {:body => message, :type => type}}.to_json
      room_id = room_id(room_id_or_name)
      url = "https://#{subdomain}.campfirenow.com/room/#{room_id}/speak.json"
      http = EventMachine::HttpRequest.new(url).post :head => {'Content-Type' => 'application/json', 'authorization' => [api_key, 'X']}, :body => Yajl::Encoder.encode({:message => {:body => payload, :type => type}})
      http.errback { logger.error "Couldn't connect to #{url} to post message \"#{payload}\" to room #{room_id}" }
      http.callback {
        if [200,201].include? http.response_header.status
          logger.debug "Posted message \"#{payload}\" to room #{room_id}"
        else
          logger.error "Couldn't post message \"#{payload}\" to room #{room_id} using url #{url}, http response from the API was #{http.response_header.status}"
        end
      }
    end

  end
end
