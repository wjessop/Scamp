# Scamp

A framework for writing [Campfire](http://campfirenow.com/) bots. Scamp is in early development so use it at your own risk, pull requests welcome.

Scamp is designed to be simple, to get out of your way and to let you do what you want. It doesn't have any baggage, so no administration web interfaces, no built in commands. It's a blank slate for you to build on.

## Requirements

Ruby >= 1.9.2 (At least for the named captures)

## Installation

`gem install scamp` or put `gem 'scamp'` in your Gemfile.

## Usage and Examples

Matchers are tested in order and all that satisfy the match and conditions will be run. Careful, Scamp listens to itself, you could easily create an infinite loop. Look in the examples dir for more.

    require 'scamp'

    # Add :verbose => true to get debug output, otherwise the logger will output INFO
    scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :verbose => true)
    
    scamp.behaviour do
      # 
      # Simple matching based on regex or string:
      # 
      match /^repeat (\w+), (\w+)$/ do
        say "You said #{matches[0]} and #{matches[1]}"
      end
      
      # 
      # A special user and channel method is available in match blocks.
      # 
      match "a user said" do
        say "#{user} said something in channel #{channel}"
      end
      
      match "Hello!" do
        say "Hi there"
      end
      
      # 
      # You can play awesome sounds
      # 
      match "ohmy" do
        play "yeah"
      end
      
      # 
      # Limit the match to certain channels, users or both.
      # 
      match /^Lets match (.+)$/, :conditions => {:channel => "Some Channel"} do
        say "Only said if channel name mathces /someregex/"
      end
      
      match "some text", :conditions => {:user => "Some User"} do
        say "Only said if user name mathces /someregex/"
      end
      
      match /some other text/, :conditions => {:user => "Some User", :channel => 123456} do
        say "You can mix conditions"
      end
      
      # 
      # Named captures become avaiable in your match block
      # 
      match /^say (?<yousaid>.+)$/ do
        say "You said #{yousaid}"
      end
      
      # 
      # You can say multiple times, and you can specify an alternate channel.
      # Default behaviour is to 'say' in the channel that caused the match.
      # 
      match "something" do
        say "#{user} said something in channel #{channel}"
        say "#{user} said something in channel #{channel}", 237872
        say "#{user} said something in channel #{channel}", "System Administration"
      end
      
      # 
      # A list of commands is available as command_list this matcher uses it
      # to format a help text
      # 
      match "help" do
        max_command_length = command_list.map{|cl| cl.first.to_s }.max_by(&:size).size
        format_string = "%#{max_command_length + 1}s"
        formatted_commands = command_list.map{|action, conds| "#{sprintf(format_string, action)} | #{conds.size == 0 ? '' : conds.inspect}"}
        say <<-EOS
    #{sprintf("%-#{max_command_length + 1}s", "Command match")} | Conditions
    --------------------------------------------------------------------------------
    #{formatted_commands.join("\n")}
        EOS
      end
    end
      
    # Connect and join some channels
    scamp.connect!([293788, "Monitoring"])

In the channel/user conditions you can use the name, regex or ID of a user or channel, in say you can ise a string or ID, eg:

    :conditions => {:channel => /someregex/}
    :conditions => {:channel => "some string"}
    :conditions => {:channel => 123456}

    :conditions => {:user => /someregex/}
    :conditions => {:user => "some string"}
    :conditions => {:user => 123456}

    say "#{user} said something in channel #{channel}", 237872
    say "#{user} said something in channel #{channel}", "System Administration"

By default Scamp listens to itself. This could either be fun, or dangerous, you decide. You can turn this off by passing :first\_match\_only => true in the initialisation options

        scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :first_match_only => true)

## TODO

* Write more tests
* Allow multiple values for conditions, eg: :conditions => {:channel => ["This channel", "Some channel"]}
* Add paste support
* Add option to stop bot responding to itself

## Known issues

* Bot tends to crash when it encounters an error.

## How to contribute

Here's the most direct way to get your work merged into the project:

1. Fork the project
2. Clone down your fork
3. Create a feature branch
4. Add your feature + tests
5. Make sure everything still passes by running the tests
6. If necessary, rebase your commits into logical chunks, without errors
7. Push the branch up
8. Send a pull request for your branch

Take a look at the TODO list or known issues for some inspiration if you need it.

## License

Copyright (C) 2011 by Will Jessop

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
