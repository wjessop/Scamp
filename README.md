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
require 'scamp-campfire-adapter'

Scamp.new do |scamp|
  scamp.adapter :campfire, Scamp::Campfire::Adapter, :api_key => "YOUR API KEY", 
                                                     :subdomain => "yoursubdomain",
                                                     :rooms => [293788,"Monitoring"]

  # Simple matching based on regex or string:
  scamp.match "ping" do |msg|
    say "pong"
  end
end
```

### Everyone wants an image search

``` ruby
require 'scamp'
require 'cgi'

Scamp.new do |scamp|
  scamp.adapter :campfire, Scamp::Campfire::Adapter, :api_key => "YOUR API KEY", 
                                                     :subdomain => "yoursubdomain",
                                                     :rooms => [293788,"Monitoring"]

  scamp.match /^artme (?<search>\w+)/ do |msg|
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
```

### A more in-depth run through

Matchers are tested in order and all that satisfy the match and conditions will be run. Careful, Scamp listens to itself, you could easily create an infinite loop. Look in the examples dir for more.

``` ruby
require 'scamp'

# Add :verbose => true to get debug output, otherwise the logger will output INFO
Scamp.new do |scamp|
  scamp.adapter :campfire, Scamp::Campfire::Adapter, :api_key => "YOUR API KEY", 
                                                     :subdomain => "yoursubdomain", 
                                                     :rooms => [293788,"Monitoring"],
                                                     :verbose => true

  # 
  # Simple matching based on regex or string:
  # 
  scamp.match /^repeat (\w+), (\w+)$/ do |msg|
    say "You said #{matches[0]} and #{matches[1]}"
  end

  # 
  # Named captures become available in your match block
  # 
  scamp.match /^say (?<yousaid>.+)$/ do |msg|
    say "You said #{yousaid}"
  end

  # 
  # A list of commands is available as command_list this matcher uses it
  # to format a help text
  # 
  scamp.match "help" do |msg|
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
  
```

Scamp will also run _all_ match blocks that an input string matches, you can make Scamp only run the first block it matches by passing in :first\_match\_only => true:

``` ruby
Scamp.new :first_match_only => true do |scamp|
end
```

## TODO

  * Get messages working back to adapters
	* Allow multiple values for conditions, eg: :conditions => {:user => ["Some User", "Some Other User"]}
  * Examples for writing adapters
  * Plugin system
  * Examples for writing plugins

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

* [Will Jessop](http://willj.net/)
* [Adam Holt](http://adamholt.co.uk/)

## Thanks

First class support, commits and pull requests, thanks guys!

* [Caius Durling](http://caius.name/)
* Sudara Williams of [Ramen Music](http://ramenmusic.com)

## License

See LICENSE.md
