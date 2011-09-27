class Scamp
  module Users
    # Return the user_id if we haven't got the real name and
    # kick off a user data fetch
    def username_for(user_id)
      return user_cache[user_id]["name"] if user_cache[user_id]
      fetch_data_for(user_id)
      return user_id.to_s
    end
    
    def is_me?(user_id)
      if user_cache['me']
        return user_cache['me']['id'] == user_id
      else
        fetch_data_for('me')
        return false        
      end
    end
    
    private
    
    def fetch_data_for(user_id)
      url = "https://#{subdomain}.campfirenow.com/users/#{user_id}.json"
      http = EventMachine::HttpRequest.new(url).get(:head => {'authorization' => [api_key, 'X'], "Content-Type" => "application/json"})
      http.callback do
        if http.response_header.status == 200
          logger.debug "Got the data for #{user_id}"
          update_user_cache_with(user_id, Yajl::Parser.parse(http.response)['user'])
        else
          logger.error "Couldn't fetch user data for user #{user_id} with url #{url}, http response from API was #{http.response_header.status}"
        end
      end
      http.errback do
        logger.error "Couldn't connect to #{url} to fetch user data for user #{user_id}"
      end
    end
    
    def update_user_cache_with(user_id, data)
      logger.debug "Updated user cache for #{data['name']}"
      user_cache[user_id] = data
    end
  end
end
