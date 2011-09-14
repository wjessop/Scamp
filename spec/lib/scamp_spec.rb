require "spec_helper"

describe Scamp do
  before do
    @valid_params = {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"}
  end

  describe "#initialize" do
    it "should work with valid params" do
      Scamp.new(@valid_params).should be_a(Scamp)
    end
    it "should warn if given an option it doesn't know" do
      mock_logger

      Scamp.new(@valid_params.merge(:fred => "estaire")).should be_a(Scamp)

      logger_output.should =~ /WARN.*Scamp initialized with :fred => "estaire" but NO UNDERSTAND!/
    end

    # Urg
    def mock_logger
      @logger_string = StringIO.new
      @fake_logger = Logger.new(@logger_string)
      Scamp.any_instance.should_receive(:logger).and_return(@fake_logger)
    end

    # Bleurgh
    def logger_output
      str = @logger_string.dup
      str.rewind
      str.read
    end
  end

end
