require File.expand_path("../lib/scamp", File.dirname(__FILE__))
require File.expand_path("../lib/scamp/adapter", File.dirname(__FILE__))
require File.expand_path("../lib/scamp/message", File.dirname(__FILE__))

require 'mocha'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_framework = :mocha
end


class RspecAdapter < Scamp::Adapter
  class Context;end

  def speak! msg
    push [Context.new, Scamp::Message.new(self, :body => msg)]
  end

  def connect!
    # noop!
  end
end
