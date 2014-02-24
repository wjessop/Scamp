require 'scamp/matches'

class Scamp
  class Message
    attr_reader :adapter, :match

    def initialize(adapter, args={})
      @adapter = adapter
      args.each do |arg,value|
        self.define_singleton_method arg do
          value
        end
      end
    end

    def valid? conditions
      true
    end

    def matches? trigger
      match? trigger, body
    end

    def to_s
      body
    end

    def matches
      Scamp::Matches.new(match) if match
    end

    protected

    def match?(trigger, message)
      if trigger.is_a? String
        return true if trigger == message
      elsif trigger.is_a? Regexp
        return true if (@match = trigger.match message)
      end
      return false
    end
  end
end
