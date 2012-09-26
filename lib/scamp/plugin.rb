class Scamp
  class Plugin
    def self.matchers
      @matchers ||= []
    end

    def self.match trigger, method
      self.matchers << [trigger, method]
    end

    attr_reader :bot, :options

    def initialize bot, opts={}
      @bot = bot
      @options = opts

      attach_matchers
    end

    private
      def matcher_options
        {
          :on => options[:on]
        }
      end

      def attach_matchers
        self.class.matchers.each do |trigger, method_name|
          @bot.match trigger, matcher_options, &Proc.new(&method(method_name))
        end
      end
  end
end
