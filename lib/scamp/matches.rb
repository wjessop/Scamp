class Scamp
  class Matches
    include Enumerable

    def initialize matches
      @matches = matches
      @matches.names.each do |name|
        self.class.send :define_method, name.to_sym do
          matches[name.to_sym]
        end
      end if @matches.respond_to?(:names) # 1.8 doesn't support named captures
    end

    def [] index
      @matches[1..-1][index]
    end

    def each
      @matches.each {|match| yield match }
    end
  end
end
