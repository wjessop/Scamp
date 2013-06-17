[![Build Status](https://secure.travis-ci.org/wjessop/Scamp.png?branch=master)](https://travis-ci.org/wjessop/Scamp)

# Scamp

A framework for writing [Campfire](http://campfirenow.com/) bots. Scamp is in early development so use it at your own risk, pull requests welcome.

Scamp is designed to be simple, to get out of your way and to let you do what you want. It doesn't have any baggage, so no administration web interfaces, no built in commands. It's a blank slate for you to build on.

If you like or use Scamp I'd love to hear from you. Drop me at line at will at 37signals dot com and tell me how you are using it.

## Requirements

Ruby >= 1.9.2 (At least for the named captures)

## Installation

`gem install scamp` or put `gem 'scamp'` in your Gemfile.

## Usage and Examples

### The most simple example:

``` ruby
require 'scamp'

scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :verbose => true)

scamp.behaviour do
  # Simple matching based on regex or string:
  match "ping" do
    say "pong"
  end
end

# Connect and join some rooms
scamp.connect!([293788, "Monitoring"])
```

### Everyone wants an image search

``` ruby
require 'scamp'
require 'cgi'

scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :verbose => true)

scamp.behaviour do
  match /^artme (?<search>\w+)/ do
    url = "http://ajax.googleapis.com/ajax/services/search/images?rsz=large&start=0&v=1.0&q=#{CGI.escape(search)}"
    http = EventMachine::HttpRequest.new(url).get
    http.errback { say "Couldn't get #{url}: #{http.response_status.inspect}" }
    http.callback {
      if http.response_header.status == 200
        results = Yajl::Parser.parse(http.response)
        if results['responseData']['results'].size > 0
          say results['responseData']['results'][0]['url']
        else
          say "No images matched #{search}"
        end
      else
        # logger.warn "Couldn't get #{url}"
        say "Couldn't get #{url}"
      end
    }
  end
end

# Connect and join some rooms
scamp.connect!([293788, "Monitoring"])
```

### A more in-depth run through

Matchers are tested in order and all that satisfy the match and conditions will be run. Careful, Scamp listens to itself, you could easily create an infinite loop. Look in the examples dir for more.

``` ruby
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
  # You can specifically paste text: 
  #
  
  match "paste stuff" do
    paste "Awesome texts"
    
    # say()'ing multiline strings will paste automatically however:
    say <<-EOS
This will be pasted
even though you called say
    EOS
  end
  
  # 
  # A special user and room method is available in match blocks.
  # 
  match "a user said" do
    say "#{user} said something in room #{room}"
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
  # Limit the match to certain rooms, users or both.
  # 
  match /^Lets match (.+)$/, :conditions => {:room => "Some Room"} do
    say "Only said if room name matches 'Some Room'"
  end
  
  match "some text", :conditions => {:user => "Some User"} do
    say "Only said if user name matches 'Some User'"
  end
  
  match /some other text/, :conditions => {:user => "Some User", :room => 123456} do
    say "You can mix conditions"
  end

  match "some text", :conditions => {:room => ["Some Room", "Some Other Room"]} do
    say "You can list multiple rooms"
  end

  # 
  # Named captures become available in your match block
  # 
  match /^say (?<yousaid>.+)$/ do
    say "You said #{yousaid}"
  end
  
  # 
  # You can say multiple times, and you can specify an alternate room.
  # Default behaviour is to 'say' in the room that caused the match.
  # 
  match "something" do
    say "#{user} said something in room #{room}"
    say "#{user} said something in room #{room}", 237872
    say "#{user} said something in room #{room}", "System Administration"
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
  
# Connect and join some rooms
scamp.connect!([293788, "Monitoring"])
```

In the room/user conditions and say/play commands you can use the name or ID of a user or room, eg:

``` ruby
:conditions => {:room => "some string"}
:conditions => {:room => 123456}

:conditions => {:user => "some string"}
:conditions => {:user => 123456}

say "#{user} said something in room #{room}", 237872
say "#{user} said something in room #{room}", "System Administration"
```

By default Scamp listens to itself. This could either be fun, or dangerous, you decide. You can turn this off by passing :ignore\_self => true in the initialisation options:

``` ruby
scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :ignore_self => true)
```

Scamp will also run _all_ match blocks that an input string matches, you can make Scamp only run the first block it matches by passing in :first\_match\_only => true:

``` ruby
scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :first_match_only => true)
```

Scamp will listen to all messages that are sent on the rooms it is listening on and doesn't need to be addressed by name. If you prefer to only trigger bot commands when you address your bot directly add the :required\_prefix initialisation option:

``` ruby
scamp = Scamp.new(:api_key => "YOUR API KEY", :subdomain => "yoursubdomain", :required_prefix => 'Bot: ')
```

Scamp will now require commands to begin with 'Bot: ' (or whatever you have specified), and will strip out this prefix before handing the message onto your match block.

## TODO

	* Allow multiple values for conditions, eg: :conditions => {:user => ["Some User", "Some Other User"]}

## How to contribute

Here's the most direct way to get your work merged into the project:

1. Fork the project
2. Clone down your fork
3. Create a feature branch
4. Add your feature + tests
5. Document new features in the README
6. Make sure everything still passes by running the tests
7. If necessary, rebase your commits into logical chunks, without errors
8. Push the branch up
9. Send a pull request for your branch

Take a look at the TODO list or known issues for some inspiration if you need it.

## Authors

* Will Jessop (will@willj.net)

## Thanks

First class support, commits and pull requests, thanks guys!

* [Caius Durling](http://caius.name/)
* Sudara Williams of [Ramen Music](http://ramenmusic.com)
* [Dom Hodgson](http://www.thehodge.co.uk/) (for the name)

## License

See LICENSE.md
