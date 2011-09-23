require "spec_helper"

describe Scamp do
  before do
    @valid_params = {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"} 
    @valid_user_cache_data = {123 => {"name" => "foo"}, 456 => {"name" => "bar"}}
    
    # Stub fetch for channel data
    @valid_channel_cache_data = {
      123 => {
        "id" => 123,
        "name" => "foo",
        "users" => []
      },
      456 => {
        "id" => 456,
        "name" => "bar",
        "users" => []
      }
    }
    
    @valid_channel_cache_data.keys.each do |id|
      json_response = Yajl::Encoder.encode(:room => @valid_channel_cache_data[id])
      stub_request(:get, "https://#{@valid_params[:subdomain]}.campfirenow.com/room/#{id}.json").
        with(:headers => {'Authorization'=>[@valid_params[:api_key], 'X']}).
        to_return(:status => 200, :body => json_response)
    end
  end
  
  describe "#initialize" do
    it "should work with valid params" do
      a(Scamp).should be_a(Scamp)
    end
    it "should warn if given an option it doesn't know" do
      mock_logger

      a(Scamp, :fred => "estaire").should be_a(Scamp)

      logger_output.should =~ /WARN.*Scamp initialized with :fred => "estaire" but NO UNDERSTAND!/
    end
  end

  describe "#verbose" do
    it "should default to false" do
      a(Scamp).verbose.should be_false
    end
    it "should be overridable at initialization" do
      a(Scamp, :verbose => true).verbose.should be_true
    end
  end

  describe "#logger" do
    context "default logger" do
      before { @bot = a Scamp }
      it { @bot.logger.should be_a(Logger) }
      it { @bot.logger.level.should be == Logger::INFO }
    end
    context "default logger in verbose mode" do
      before { @bot = a Scamp, :verbose => true }
      it { @bot.logger.level.should be == Logger::DEBUG }
    end
    context "overriding default" do
      before do
        @custom_logger = Logger.new("/dev/null")
        @bot = a Scamp, :logger => @custom_logger
      end
      it { @bot.logger.should be == @custom_logger }
    end
  end

  describe "#first_match_only" do
    it "should default to false" do
      a(Scamp).first_match_only.should be_false
    end
    it "should be settable" do
      a(Scamp, :first_match_only => true).first_match_only.should be_true
    end
  end

  describe "private methods" do

    describe "#process_message" do
      before do
        @bot = a Scamp
        $attempts = 0 # Yes, I hate it too. Works though.
        @message = {:body => "my message here"}

        @bot.behaviour do
          2.times { match(/.*/) { $attempts += 1 } }
        end
      end
      after { $attempts = nil }
      context "with first_match_only not set" do
        before { @bot.first_match_only.should be_false }
        it "should process all matchers which attempt the message" do
          @bot.send(:process_message, @message)
          $attempts.should be == 2
        end
      end
      context "with first_match_only set" do
        before do
          @bot.first_match_only = true
          @bot.first_match_only.should be_true
        end
        it "should only process the first matcher which attempts the message" do
          @bot.send(:process_message, @message)
          $attempts.should be == 1
        end
      end
    end
  end
  
  describe "matching" do
    
    context "with conditions" do
      it "should limit matches by channel id" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never
        
        bot = a Scamp
        bot.behaviour do
          match("a string", :conditions => {:channel => 123}) {canary.lives}
          match("a string", :conditions => {:channel => 456}) {canary.bang}
        end
        
        bot.send(:process_message, {:room_id => 123, :body => "a string"})
      end
      
      it "should limit matches by channel name" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never
        
        bot = a Scamp
        bot.behaviour do
          match("a string", :conditions => {:channel => "foo"}) {canary.lives}
          match("a string", :conditions => {:channel => "bar"}) {canary.bang}
        end
        
        bot.channel_cache = @valid_channel_cache_data
        
        bot.send(:process_message, {:room_id => 123, :body => "a string"})
      end
      
      it "should limit matches by user id" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never
        
        bot = a Scamp
        bot.behaviour do
          match("a string", :conditions => {:user => 123}) {canary.lives}
          match("a string", :conditions => {:user => 456}) {canary.bang}
        end
        
        bot.send(:process_message, {:user_id => 123, :body => "a string"})
      end
      
      it "should limit matches by user name" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never
        
        bot = a Scamp
        bot.behaviour do
          match("a string", :conditions => {:user => "foo"}) {canary.lives}
          match("a string", :conditions => {:user => "bar"}) {canary.bang}
        end
        
        bot.user_cache = @valid_user_cache_data
        
        bot.send(:process_message, {:user_id => 123, :body => "a string"})
      end
      
      it "should limit matches by channel and user" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never
        
        bot = a Scamp
        bot.behaviour do
          match("a string", :conditions => {:channel => 123, :user => 123}) {canary.lives}
          match("a string", :conditions => {:channel => 456, :user => 456}) {canary.bang}
        end
        
        bot.channel_cache = @valid_channel_cache_data
        bot.user_cache = @valid_user_cache_data
        bot.send(:process_message, {:room_id => 123, :user_id => 123, :body => "a string"})
        bot.send(:process_message, {:room_id => 123, :user_id => 456, :body => "a string"})
        bot.send(:process_message, {:room_id => 456, :user_id => 123, :body => "a string"})
      end
    end
    
    describe "strings" do
      it "should match an exact string" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never
        
        bot = a Scamp
        bot.behaviour do
          match("a string") {canary.lives}
          match("another string") {canary.bang}
          match("a string like no other") {canary.bang}
        end
        
        bot.send(:process_message, {:body => "a string"})
      end
      
      it "should not match without prefix when required_prefix is true" do
        canary = mock
        canary.expects(:bang).never
        
        bot = a Scamp, :required_prefix => 'Bot: '
        bot.behaviour do
          match("a string") {canary.bang}
        end
        
        bot.send(:process_message, {:body => "a string"})
      end

      it "should match with exact prefix when required_prefix is true" do
        canary = mock
        canary.expects(:lives).once
        
        bot = a Scamp, :required_prefix => 'Bot: '
        bot.behaviour do
          match("a string") {canary.lives}
        end
        
        bot.send(:process_message, {:body => "Bot: a string"})
      end
    end
    

    describe "regexes" do
      it "should match a regex" do
        canary = mock
        canary.expects(:ping).twice
        
        bot = a Scamp
        bot.behaviour do
          match /foo/ do
            canary.ping
          end
        end
        
        bot.send(:process_message, {:body => "something foo other thing"})
        bot.send(:process_message, {:body => "foomaster"})
      end
      
      it "should make named captures vailable as methods" do
        canary = mock
        canary.expects(:one).with("first")
        canary.expects(:two).with("the rest of it")
        
        bot = a Scamp
        bot.behaviour do
          match /^please match (?<yousaidthis>\w+) and (?<andthis>.+)$/ do
            canary.one(yousaidthis)
            canary.two(andthis)
          end
        end
        
        bot.send(:process_message, {:body => "please match first and the rest of it"})
      end
      
      it "should make matches available in an array" do
        canary = mock
        canary.expects(:one).with("first")
        canary.expects(:two).with("the rest of it")
        
        bot = a Scamp
        bot.behaviour do
          match /^please match (\w+) and (.+)$/ do
            canary.one(matches[0])
            canary.two(matches[1])
          end
        end
        
        bot.send(:process_message, {:body => "please match first and the rest of it"})
      end
      
      it "should not match without prefix when required_prefix is present" do
        canary = mock
        canary.expects(:bang).never
        
        bot = a Scamp, :required_prefix => /^Bot[\:,\s]+/i
        bot.behaviour do
          match(/a string/) {canary.bang}
        end
        
        bot.send(:process_message, {:body => "a string"})
        bot.send(:process_message, {:body => "some kind of a string"})
        bot.send(:process_message, {:body => "a string!!!"})
      end

      it "should match with regex prefix when required_prefix is present" do
        canary = mock
        canary.expects(:lives).times(4)
        
        bot = a Scamp, :required_prefix => /^Bot\W{1,2}/i
        bot.behaviour do
          match(/a string/) {canary.lives}
        end
        
        bot.send(:process_message, {:body => "Bot, a string"})
        bot.send(:process_message, {:body => "Bot a string"})
        bot.send(:process_message, {:body => "bot: a string"})
        bot.send(:process_message, {:body => "Bot: a string oh my!"})
      end
    end
  end
  
  describe "match block" do
    it "should make the channel details available to the action block" do
      canary = mock
      canary.expects(:id).with(123)
      canary.expects(:name).with(@valid_channel_cache_data[123]["name"])
      
      bot = a Scamp
      bot.behaviour do
        match("a string") {
          canary.id(channel_id)
          canary.name(channel)
        }
      end
      
      bot.channel_cache = @valid_channel_cache_data
      bot.send(:process_message, {:room_id => 123, :body => "a string"})
    end
    
    it "should make the speaking user details available to the action block" do
      canary = mock
      canary.expects(:id).with(123)
      canary.expects(:name).with(@valid_user_cache_data[123]["name"])
      
      bot = a Scamp
      bot.behaviour do
        match("a string") {
          canary.id(user_id)
          canary.name(user)
        }
      end
      
      bot.user_cache = @valid_user_cache_data
      bot.send(:process_message, {:user_id => 123, :body => "a string"})
    end
    
    it "should make the message said available to the action block" do
      canary = mock
      canary.expects(:message).with("Hello world")
      
      bot = a Scamp
      bot.behaviour do
        match("Hello world") {
          canary.message(message)
        }
      end
      
      bot.send(:process_message, {:body => "Hello world"})
    end
    
    it "should provide a command list" do
      canary = mock
      canary.expects(:commands).with([["Hello world", {}], ["Hello other world", {:channel=>123}], [/match me/, {:user=>123}]])
      
      bot = a Scamp
      bot.behaviour do
        match("Hello world") {
          canary.commands(command_list)
        }
        match("Hello other world", :conditions => {:channel => 123}) {}
        match(/match me/, :conditions => {:user => 123}) {}
      end
      
      bot.send(:process_message, {:body => "Hello world"})
    end
    
    it "should be able to play a sound to the channel the action was triggered in" do
      bot = a Scamp
      bot.behaviour do
        match("Hello world") {
          play "yeah"
        }
      end
      
      EM.run_block {
        room_id = 123
        stub_request(:post, "https://#{@valid_params[:subdomain]}.campfirenow.com/room/#{room_id}/speak.json").
          with(
            :body => "{\"message\":{\"body\":\"yeah\",\"type\":\"SoundMessage\"}}",
            :headers => {'Authorization'=>[@valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}
          )
            
        bot.send(:process_message, {:room_id => room_id, :body => "Hello world"})
      }
    end
    
    it "should be able to play a sound to an arbitrary channel" do
      play_channel = 456
      
      bot = a Scamp
      bot.behaviour do
        match("Hello world") {
          play "yeah", play_channel
        }
      end
      
      EM.run_block {
        room_id = 123
        stub_request(:post, "https://#{@valid_params[:subdomain]}.campfirenow.com/room/#{play_channel}/speak.json").
          with(
            :body => "{\"message\":{\"body\":\"yeah\",\"type\":\"SoundMessage\"}}",
            :headers => {'Authorization'=>[@valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}
          )
            
        bot.send(:process_message, {:room_id => room_id, :body => "Hello world"})
      }
    end
    
    it "should be able to say a message to the channel the action was triggered in" do
      bot = a Scamp
      bot.behaviour do
        match("Hello world") {
          say "yeah"
        }
      end
      
      EM.run_block {
        room_id = 123
        stub_request(:post, "https://#{@valid_params[:subdomain]}.campfirenow.com/room/#{room_id}/speak.json").
          with(
            :body => "{\"message\":{\"body\":\"yeah\",\"type\":\"Textmessage\"}}",
            :headers => {'Authorization'=>[@valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}
          )
            
        bot.send(:process_message, {:room_id => room_id, :body => "Hello world"})
      }
    end
    
    it "should be able to say a message to an arbitrary channel" do
      play_channel = 456
      
      bot = a Scamp
      bot.behaviour do
        match("Hello world") {
          say "yeah", play_channel
        }
      end
      
      EM.run_block {
        room_id = 123
        stub_request(:post, "https://#{@valid_params[:subdomain]}.campfirenow.com/room/#{play_channel}/speak.json").
          with(
            :body => "{\"message\":{\"body\":\"yeah\",\"type\":\"Textmessage\"}}",
            :headers => {'Authorization'=>[@valid_params[:api_key], 'X'], 'Content-Type'=>'application/json'}
          )
            
        bot.send(:process_message, {:room_id => room_id, :body => "Hello world"})
      }
    end
  end

  def a klass, params={}
    params ||= {}
    params = @valid_params.merge(params) if klass == Scamp
    klass.new(params)
  end

  # Urg
  def mock_logger
    @logger_string = StringIO.new
    @fake_logger = Logger.new(@logger_string)
    Scamp.any_instance.expects(:logger).returns(@fake_logger)
  end

  # Bleurgh
  def logger_output
    str = @logger_string.dup
    str.rewind
    str.read
  end
end
