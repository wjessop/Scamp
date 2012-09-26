require "spec_helper"

describe Scamp do
  describe "#initialize" do
    it "should work with valid params" do
      Scamp.new do |scamp|
        scamp.should be_a(Scamp)
      end
    end

    it "should warn if given an option it doesn't know" do
      mock_logger

      Scamp.new :fred => "estaire" do |scamp|
      end

      logger_output.should =~ /WARN.*Scamp initialized with :fred => "estaire" but NO UNDERSTAND!/
    end
  end

  describe "#verbose" do
    it "should default to false" do
      Scamp.new do |scamp|
        scamp.verbose.should be_false
      end
    end

    it "should be overridable at initialization" do
      Scamp.new :verbose => true do |scamp|
        scamp.verbose.should be_true
      end
    end
  end

  describe "#logger" do
    context "default logger" do
      before do
        Scamp.new do |scamp|
          @bot = scamp
        end
      end

      it "has a log level of INFO" do
        @bot.logger.should be_a(Logger)
        @bot.logger.level.should be == Logger::INFO
      end
    end

    context "default logger in verbose mode" do
      before do
       Scamp.new :verbose => true do |scamp|
         @bot = scamp
       end
      end

      it "has a log level of DEBUG" do
        @bot.logger.level.should be == Logger::DEBUG
      end
    end

    context "overriding default" do
      before do
        @custom_logger = Logger.new("/dev/null")
        Scamp.new :logger => @custom_logger do |scamp|
          @bot = scamp
        end
      end

      it "uses the custom logger provided" do
        @bot.logger.should be == @custom_logger
      end
    end
  end

  describe "#first_match_only" do
    it "should default to false" do
      Scamp.new do |scamp|
        scamp.first_match_only.should be_false
      end
    end
    it "should be settable" do
      Scamp.new :first_match_only => true do |scamp|
        scamp.first_match_only.should be_true
      end
    end
  end

  describe "matching" do
    describe "strings" do
      it "should match an exact string" do
        canary = mock
        canary.expects(:lives).once
        canary.expects(:bang).never

        EM.run_block do
          Scamp.new do |bot|
            bot.adapter :rspec, RspecAdapter

            bot.match("a string") {|context, message| canary.lives }
            bot.match("another string") {|context, message| canary.bang }
            bot.match("a string like no other") {|context, message| canary.bang }

            bot.connect!
            bot.adapters[:rspec][:adapter].speak! "a string"
          end
        end
      end
    end


    describe "regexes" do
      it "should match a regex" do
        canary = mock
        canary.expects(:ping).twice
        EM.run_block do
          Scamp.new do |bot|
            bot.adapter :rspec, RspecAdapter

            bot.match /foo/ do
              canary.ping
            end

            bot.connect!
            bot.adapters[:rspec][:adapter].speak! "something foo other thing"
            bot.adapters[:rspec][:adapter].speak! "foomaster"
          end
        end
      end

      it "should make named captures available on the message" do
        canary = mock
        canary.expects(:one).with("first")
        canary.expects(:two).with("the rest of it")

        EM.run_block do
          Scamp.new do |bot|
            bot.adapter :rspec, RspecAdapter

            bot.match /^please match (?<yousaidthis>\w+) and (?<andthis>.+)$/ do |channel, msg|
              canary.one(msg.matches.yousaidthis)
              canary.two(msg.matches.andthis)
            end

            bot.connect!
            bot.adapters[:rspec][:adapter].speak! "please match first and the rest of it"
          end
        end
      end

      it "should make matches available in an array" do
        canary = mock
        canary.expects(:one).with("first")
        canary.expects(:two).with("the rest of it")

        EM.run_block do
          Scamp.new do |bot|
            bot.adapter :rspec, RspecAdapter

            bot.match /^please match (\w+) and (.+)$/ do |channel, msg|
              canary.one(msg.matches[0])
              canary.two(msg.matches[1])
            end

            bot.connect!
            bot.adapters[:rspec][:adapter].speak! "please match first and the rest of it"
          end
        end
      end
    end
  end

  describe ".adapter" do
    let(:adapter) { mock }
    before do
      RspecAdapter.stubs(:new) do
        adapter
      end
    end

    it "subscribes to an adapter" do
      adapter.expects(:subscribe).once
      RspecAdapter.stubs(:new).returns adapter

      Scamp.new do |scamp|
        scamp.adapter :rspec_adapter, RspecAdapter
      end
    end
  end

  # Urg
  def mock_logger
    @logger_string = StringIO.new
    @fake_logger = Logger.new(@logger_string)
    Scamp.any_instance.expects(:logger).at_least(1).returns(@fake_logger)
  end

  # Bleurgh
  def logger_output
    str = @logger_string.dup
    str.rewind
    str.read
  end
end
