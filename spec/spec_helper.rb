require File.expand_path("../lib/scamp", File.dirname(__FILE__))
require 'mocha'
RSpec.configure do |config|
  config.mock_framework = :mocha
end