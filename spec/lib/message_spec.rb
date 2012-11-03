require 'spec_helper'

describe Scamp::Message do
  describe "#new" do
    it "requires a body attribute" do
      expect {
        Scamp::Message.new('foo')
      }.to raise_error(ArgumentError)
    end

    it "should store and provide access to metadata" do
      msg = Scamp::Message.new("foo", body: "hello", foo: "foo", bar: "bar")
      msg.foo.should eql("foo")
      msg.bar.should eql("bar")
    end

    it "should maintain metadata integrity when multiple instances exist" do
      msg = Scamp::Message.new("foo", body: "hello", foo: "foo")
      msg2 = Scamp::Message.new("foo", body: "hello", foo: "ouchie")
      msg.foo.should eql("foo")
      msg.foo.should eql("foo")
    end

    it "should isolate data access message instances created by different adapters" do
      msg = Scamp::Message.new("foo", body: "hello", foo: "foo")
      msg2 = Scamp::Message.new("foo2", body: "hello", bar: "bar")

      msg.should respond_to(:foo)
      msg.should_not respond_to(:bar)

      msg2.should respond_to(:bar)
      msg2.should_not respond_to(:foo)
    end
  end

  describe ".valid?" do
    it "returns true by default" do
      msg = Scamp::Message.new('foo', body: "hello")
      msg.valid?(nil).should be_true
    end
  end

  describe ".matches?" do
    let(:msg) { Scamp::Message.new('foo', body: "hello") }

    it "matches a string trigger" do
      msg.matches?("hello").should be_true
    end

    it "matches a regex trigger" do
      msg.matches?(/^hello$/).should be_true
    end

    it "does not match an invalid matcher" do
      msg.matches?("goodbye").should be_false
    end
  end
end
