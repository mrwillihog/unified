# Unified

Unified is a gem for parsing unified diff files into usable diff files.

## Installation

Add this line to your application's Gemfile:

    gem 'unified'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unified

## Usage

To parse a diff file:

    Unified::Diff.parse!(diff_content)

Where diff_content is a valid unified diff string.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
