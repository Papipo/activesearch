# ActiveSearch

This gem allows any class to be indexed by the chosen fulltext search engine.

## Installation

Add this line to your application's Gemfile:

    gem 'activesearch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activesearch

## Supported engines

###Mongoid

This is not a fulltext search engine, but it's a good solution for those users that don't have access to anything else.
It works by storing keywords taken from the specified fields and storing them in an Array field, which would be indexed.
search() method will return a Mongod::Criteria, so you can chain it with further scopes, like pagination.
You won't get original documents though.

## Usage

    class SomeModel
      # [...] field definitions if needed
      include ActiveSearch::Engine # "Engine" being your chosen engine ie. "Mongoid"
  
      search_on :title, :body, store: [:title]
    end
    
    # Access the stored fields so you don't need to fetch the real document
    SomeModel.search("some words").first.stored["title"]


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
