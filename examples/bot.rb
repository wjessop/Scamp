#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'scamp'

scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "37s")

scamp.behaviour do
  # Match some regex limited to a room condition based on a room id
  match /^room id (.+)$/, :conditions => {:room => 401839} do
    # Reply in the current room
    say "Match some regex limited to a room condition based on a room id"
  end

  # Limit a match to a room condition based on a string
  match "room name check", :conditions => {:room => "Monitoring"} do
    say "Limit a match to a room condition based on a string"
  end

  # Limit a match to a user condition based on a string
  match /^user name (.+)$/, :conditions => {:user => "Will Jessop"} do
    say "Limit a match to a user condition based on a string"
  end

   # Limit a match to a user condition based on a string
   match "user id check", :conditions => {:user => 774016} do
     say "Limit a match to a user condition based on an ID"
   end

   # Limit a match to a room & user condition combined
   match /^something (.+)$/, :conditions => {:room => "Monitoring", :user => "Will Jessop"} do
     # Reply in the current room
     say "Limit a match to a room & user condition combined"
   end

   # Match text with a regex, access the captures from the match object
   match /^repeat (\w+), (\w+)$/ do
     say "You said #{matches[0]} and #{matches[1]}"
   end

   # Match text with a regex, access the named captures as a method
   match /^say (?<yousaid>.+)$/ do
     say "You said #{yousaid}"
   end

   # Simple string match, interpolating the room and user in response.
   match "something" do |data|
     # Send the response to a different room
     say "#{user} said something in room #{room}", "Robot Army"

     # Send the response to a different room, using the room ID
     say "#{user} said something in room #{room}", 293788

     # Send the response to the originating room
     say "#{user} said something in room #{room}"
   end

   # Play some sounds
   match "ohmy" do
     play "yeah"
     play "drama"
   end

   match "multi-condition match", :conditions => {:room => [401839, "Monitoring"], :user => ["Will Jessop", "Noah Lorang"]} do
     # Reply in the current room
     say "multi-condition match"
   end
end

# FIXME: this does if the room doesn't exist. Need a better error.
scamp.connect!([293788, "Monitoring"])
