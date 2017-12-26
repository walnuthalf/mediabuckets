# Mediabuckets
This gem can parse a directory recursively, filter identical files (based on SHA2), and then sort all files by their media types, which are determined by MIME types. 

mimemagic gem was used for determining MIME types.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mediabuckets', :git => git@github.com:walnuthalf/mediabuckets.git
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mediabuckets

## Usage
Mediabuckets::Action.arrange can symbolically link, copy, or move sorted files.
Use move with caution.
```ruby
require "mediabuckets"
Mediabuckets::Action.arrange("/home/mk/Downloads", "/home/mk/sorted", "link")
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
