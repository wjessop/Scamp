require 'spec_helper'

describe Scamp::Plugin do
  describe "#matchers" do
    it "is empty by default" do
      Scamp::Plugin.matchers.should be_empty
    end

    it "should add a new matcher" do
      expect {
        Scamp::Plugin.match "Hello", :method
      }.to change { Scamp::Plugin.matchers.size }.by(1)
    end

    describe ".new" do
      let(:bot) { mock }
      let(:plugin) { 
        class TestPlugin < Scamp::Plugin
          match "Hello", :name

          def name(context, msg)
          end
        end
        TestPlugin
      }

      it "attaches matchers to the bot" do
        bot.expects(:match).with("Hello", {:on => nil}).once
        plugin.new(bot)
      end
    end
  end
end
