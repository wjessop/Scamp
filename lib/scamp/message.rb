class Scamp
  class Message
    attr_reader :matches

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
        match = trigger.match body
        if match
          setup_captures match
          return true
        end
        return false
      end
    end

    private
      def setup_captures(match)
        @matches = match[1..-1]
        match.names.each do |name|
          name_s = name.to_sym
          self.class.send :define_method, name_s do
            match[name_s]
          end
        end if match.respond_to?(:names) # 1.8 doesn't support named captures
      end
  end
end
