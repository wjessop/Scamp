require 'spec_helper'

describe Scamp::Adapter do
  let(:bot) { stub }
  describe "#new" do
    it "creates a new adapter" do
      adapter = Scamp::Adapter.new(bot)
      adapter.should_not be_nil
    end

    it "accepts a hash of options" do
      adapter = Scamp::Adapter.new(bot, :hello => "world")
      adapter.should_not be_nil
    end
  end

  describe ".matches_required_format?" do
    let(:adapter) { Scamp::Adapter.new(bot) }
    let(:bot) { stub(:required_format => nil) }

    describe "no requirement" do
      it "matches required format" do
        adapter.matches_required_format?("Hello").should be_true
      end
    end

    describe "string requirement" do
      let(:bot) { stub(:required_format => "Bot: ") }

      it "matches msg with correct prefix" do
        adapter.matches_required_format?("Bot: Hello").should be_true
      end

      it "does not match msg with incorrect prefix" do
        adapter.matches_required_format?("Not: Hello").should be_false
      end
    end

    describe "regex requirement" do
      let(:bot) { stub(:required_format => /^Bot: /) }

      it "matches msg with correct prefix" do
        adapter.matches_required_format?("Bot: Hello").should be_true
      end

      it "does not match msg with incorrect prefix" do
        adapter.matches_required_format?("Not: Hello").should be_false
      end
    end

    describe "other requirement" do
      let(:bot) { stub(:required_format => Object.new) }

      it "raises an ArgumentError" do
        expect {
          adapter.matches_required_format?("Bot: Hello").should be_true
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe ".strip_prefix" do
    describe "with strip_prefix enabled" do
      describe "with a string require_format" do
        let(:adapter) { Scamp::Adapter.new(bot) }
        let(:bot) { stub(:required_format => "Bot: ", :strip_prefix => true) }

        it "should strip the required_format if it is a string" do
          adapter.strip_prefix("Bot: Hello").should == "Hello"
        end

        it "should not strip an incorrect prefix" do
          adapter.strip_prefix("Not: Hello").should == "Not: Hello"
        end
      end

      describe "with a Regex require_format" do
        let(:adapter) { Scamp::Adapter.new(bot) }
        let(:bot) { stub(:required_format => /^Bot: /, :strip_prefix => true) }

        it "should strip the required_format if it is a string" do
          adapter.strip_prefix("Bot: Hello").should == "Bot: Hello"
        end

        it "should not strip an incorrect prefix" do
          adapter.strip_prefix("Not: Hello").should == "Not: Hello"
        end
      end
    end

    describe "with strip_prefix disabled" do
      let(:adapter) { Scamp::Adapter.new(bot) }
      let(:bot) { stub(:required_format => "Bot: ", :strip_prefix => false) }

      it "should strip the required_format if it is a string" do
        adapter.strip_prefix("Bot: Hello").should == "Bot: Hello"
      end

      it "should not strip an incorrect prefix" do
        adapter.strip_prefix("Not: Hello").should == "Not: Hello"
      end
    end
  end

  describe "channels" do
    let(:adapter) { Scamp::Adapter.new(bot) }

    describe ".push" do
      it "should push through the correct value" do
        EM.run_block do
          value = nil
          adapter.subscribe do |msg|
            value = msg
          end
          adapter.push "Hello World"

          value.should == "Hello World"
        end
      end
    end

    describe ".subscribe" do
      it "allows subscriptions" do
        EM.run_block do
          subscribed = false
          adapter.subscribe do |msg|
            subscribed = true
          end
          adapter.push true

          subscribed.should be_true
        end
      end
    end
  end

  describe ".connect!" do
    let(:adapter) { Scamp::Adapter.new(bot) }
    it "should raise an implementation error" do
      expect {
        adapter.connect!
      }.to raise_error(NotImplementedError)
    end
  end
end
