require 'spec_helper'

describe Scamp::Message do
	it "should store and provide access to metadata" do
		msg = Scamp::Message.new("foo", {"foo" => "foo", :bar => "bar"})
		msg.foo.should eql("foo")
		msg.bar.should eql("bar")
	end

	it "should maintain metadata integrity when multiple instances exist" do
		msg = Scamp::Message.new("foo", {"foo" => "foo"})
		msg2 = Scamp::Message.new("foo", {"foo" => "ouchie"})
		msg.foo.should eql("foo")
		msg.foo.should eql("foo")
	end

	it "should isolate data access message instances created by different adapters" do
		msg = Scamp::Message.new("foo", {"foo" => "foo"})
		msg2 = Scamp::Message.new("foo2", {"bar" => "bar"})

		msg.should respond_to(:foo)
		msg.should_not respond_to(:bar)

		msg2.should respond_to(:bar)
		msg2.should_not respond_to(:foo)
	end
end