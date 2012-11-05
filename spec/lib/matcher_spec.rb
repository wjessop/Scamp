require 'spec_helper'

describe Scamp::Matcher do
  describe "#new" do
    let(:bot) { stub(adapters: {one: "two"}) }

    it "requires a trigger" do
      expect {
        Scamp::Matcher.new(bot, action: ->(ctx, msg){})
      }.to raise_error(ArgumentError)
    end

    it "requires a action" do
      expect {
        Scamp::Matcher.new(bot, trigger: "Hello")
      }.to raise_error(ArgumentError)
    end
  end

  describe ".attempt" do
    context "channels" do
      let(:msg) { Scamp::Message.new stub, body: "hello" }

      context "listened" do
        it "runs the action when" do
          result = false
          matcher = Scamp::Matcher.new stub,
                                         on: [:one],
                                    trigger: "hello",
                                     action: ->(ctx, msg){result = true}
          matcher.attempt(:one, stub, msg)
          result.should be_true
        end
      end

      context "unlistened" do
        it "does not run the action" do
          result = false
          matcher = Scamp::Matcher.new stub,
                                         on: [:one],
                                    trigger: "hello",
                                     action: ->(ctx, msg){result = true}
          matcher.attempt(:two, stub, msg)
          result.should be_false
        end
      end
    end

    context "triggers" do
      context "matching" do
        it "runs the action" do
          result = false
          matcher = Scamp::Matcher.new stub,
                                         on: [:one],
                                    trigger: "hello",
                                     action: ->(ctx, msg){result = true}
          msg = Scamp::Message.new stub, body: "hello"

          matcher.attempt(:one, stub, msg)
          result.should be_true
        end
      end

      context "non matching" do
        it "runs the action" do
          result = false
          matcher = Scamp::Matcher.new stub,
                                         on: [:one],
                                    trigger: "hello",
                                     action: ->(ctx, msg){result = true}
          msg = Scamp::Message.new stub, body: "goodbye"

          matcher.attempt(:one, stub, msg)
          result.should be_false
        end
      end
    end

    context "validations" do
      let(:message_class) {
        class MyMessage < Scamp::Message
          def valid?(conditions)
            conditions[:hello] == "world"
          end
        end
        MyMessage
      }

      context "valid message" do
        it "runs the action" do
          result = false
          matcher = Scamp::Matcher.new stub,
                                         on: [:one],
                                    trigger: "hello",
                                     action: ->(ctx, msg){result = true},
                                 conditions: {hello: "world"}

          msg = message_class.new stub, body: "hello"

          matcher.attempt(:one, stub, msg)
          result.should be_true
        end
      end

      context "invalid message" do
        it "runs the action" do
          result = false
          matcher = Scamp::Matcher.new stub,
                                         on: [:one],
                                    trigger: "hello",
                                     action: ->(ctx, msg){result = true},
                                 conditions: {hello: "goodbye"}

          msg = message_class.new stub, body: "hello"

          matcher.attempt(:one, stub, msg)
          result.should be_false
        end
      end
    end
  end
end
