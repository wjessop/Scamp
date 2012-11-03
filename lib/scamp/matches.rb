class Scamp
  class Matches
    include Enumerable

    def initialize matches
      @matches = matches
      @matches.names.each do |name|
        self.define_singleton_method name.to_sym do
          matches[name.to_sym]
        end
      end
    end

    def [] index
      @matches[1..-1][index]
    end

    def each
      @matches[1..-1].each {|match| yield match }
    end
  end
end
