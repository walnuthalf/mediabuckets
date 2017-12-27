# Mediabuckets
This gem can parse a directory recursively, filter identical files (based on SHA2), and then sort all files by their media types, which are determined by MIME types. 
mimemagic gem was used for determining MIME types.


Tested on Fedora 25, but should work in most UNIX-like systems.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mediabuckets', :git => git@github.com:walnuthalf/mediabuckets.git
```

And then execute:

    $ bundle

## Usage
Mediabuckets.arrange(source, destination, command) can symbolically link, copy, or move sorted files.
Use move with caution.
```ruby
require "mediabuckets"
Mediabuckets.arrange("/home/mk/Downloads", "/home/mk/sorted", "link")
```
Log events are saved in \_\_log\_\_ file in the destination folder in JSON format. 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
