class Scamp
  module Users
    
    # <user>
    #   <id type="integer">1</id>
    #   <name>Jason Fried</name>
    #   <email-address>jason@37signals.com</email-address>
    #   <admin type="boolean">true</admin>
    #   <created-at type="datetime">2009-11-20T16:41:39Z</created-at>
    #   <type>Member</type>
    #   <avatar-url>http://asset0.37img.com/global/.../avatar.png</avatar-url>
    # </user>
    
    # Return the user_id if we haven't got the real name and
    # kick off a user data fetch
    def username_for(user_id)
      return user_cache[user_id]["name"] if user_cache[user_id]
      fetch_data_for(user_id)
      return user_id.to_s
    end
    
    private
    
    def fetch_data_for(user_id)
      url = "https://#{subdomain}.campfirenow.com/users/#{user_id}.json"
      http = EventMachine::HttpRequest.new(url).get(:head => {'authorization' => [api_key, 'X'], "Content-Type" => "application/json"})
      puts http.inspect
      http.callback do
        STDERR.puts "Got the data for #{user_id}"
        update_user_cache_with(user_id, Yajl::Parser.parse(http.response)['user'])
      end
      http.errback do
        STDERR.puts "Couldn't fetch user data for #{user_id} with url #{url}"
        STDERR.puts http.response_header.status
        STDERR.puts http.response_header.inspect
        STDERR.puts http.response.inspect
      end
    end
    
    def update_user_cache_with(user_id, data)
      STDERR.puts "Updated user cache for #{data['name']}"
      user_cache[user_id] = data
    end
  end
end
