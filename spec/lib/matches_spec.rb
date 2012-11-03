require 'spec_helper'

describe Scamp::Matches do
  let(:msg) { "Name: Scamp, URL: https://github.com/wjessop/Scamp/" }
  let(:match) { msg.match(/^Name: (?<name>\w+), URL: (?<url>.*)/) }
  let(:matches) { Scamp::Matches.new(match) }

  it "exposes the name from the capture" do
    matches.name.should eql("Scamp")
    matches[0].should eql("Scamp")
  end

  it "exposes the url from the capture" do
    matches.url.should eql("https://github.com/wjessop/Scamp/")
    matches[1].should eql("https://github.com/wjessop/Scamp/")
  end

  describe '.each' do
    it "iterates over each match" do
      results = []
      matches.each do |match|
        results << match
      end

      results.should include("Scamp")
      results.should include("https://github.com/wjessop/Scamp/")
    end
  end
end
