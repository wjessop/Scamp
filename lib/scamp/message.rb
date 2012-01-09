class Scamp
  class Message
    def initialize(adapter, args={})
      raise ArgumentError, "A Message must have a body" unless args[:body]
      args.each do |k,v|
        self.class.send :define_method, k do
          v
        end
      end
    end

    def valid? conditions
      true
    end

    def matches? trigger
      if trigger.is_a? String
        trigger == body
      elsif trigger.is_a? Regexp
        trigger.match body
      end
    end
  end
end
