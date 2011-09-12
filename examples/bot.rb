#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'Scamp'

scamp = Scamp.new(:api_key => "YOUR API KEY")

Scamp.behaviour do
  # Match some regex limited to a channel condition based on a channel id
  match /^channel id (.+)$/, :conditions => {:channel => 401839} do
    # Reply in the current channel
    say "Match some regex limited to a channel condition based on a channel id"
  end
  
  # Limit a match to a channel condition based on a string
  match "channel name check", :conditions => {:channel => "Monitoring"} do
    say "Limit a match to a channel condition based on a string"
  end
  
  # Limit a match to a channel condition based on a regex
  match /^channel regex (.+)$/, :conditions => {:channel => /someregex/} do
    say "Limit a match to a channel condition based on a regex"
  end
  
  # Limit a match to a user condition based on a regex
  match /^user regex (.+)$/, :conditions => {:user => /someregex/} do
    say "Limit a match to a user condition based on a regex"
  end

  # Limit a match to a user condition based on a string
  match /^user name (.+)$/, :conditions => {:user => "Will Jessop"} do
    say "Limit a match to a user condition based on a string"
  end
  
   # Limit a match to a user condition based on a string
   match "user id check", :conditions => {:user => 774016} do
     say "Limit a match to a user condition based on an ID"
   end
   
   # Limit a match to a channel & user condition combined
   match /^something (.+)$/, :conditions => {:channel => "Monitoring", :user => "Will Jessop"} do
     # Reply in the current channel
     say "Limit a match to a channel & user condition combined"
   end
     
   # Match text with a regex, access the captures from the match object
   match /^repeat (\w+), (\w+)$/ do
     say "You said #{matches[0]} and #{matches[1]}"
   end
   
   # Match text with a regex, access the named captures as a method
   match /^say (?<yousaid>.+)$/ do
     say "You said #{yousaid}"
   end
   
   # Simple string match, interpolating the channel and user in response.
   match "something" do |data|
     # Send the response to a different channel
     say "#{user} said something in channel #{channel}", "Robot Army"
     
     # Send the response to a different channel, using the channel ID
     say "#{user} said something in channel #{channel}", 293788
     
     # Send the response to the originating channel
     say "#{user} said something in channel #{channel}"
   end
   
   match "multi-condition match", :conditions => {:channel => [401839, "Monitoring"], :nick => ["Will Jessop", "Noah Lorang"]} do
     # Reply in the current channel
     say "multi-condition match"
   end
end

# FIXME: this does if the channel doesn't exist. Need a better error.
scamp.connect!([293788, "Monitoring"])