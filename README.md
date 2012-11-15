# ActiveSearch

This gem allows any class to be indexed by the chosen fulltext search engine.

## Installation

Depending on the chosen engine, you need to require a dependency and then activesearch on your Gemfile:

###Mongoid

    gem 'mongoid'
    gem 'activesearch'
    
This is not a fulltext search engine, but it's a good solution for those users that don't have access to anything else.
It works by storing keywords taken from the specified fields and storing them in an Array field, which would be indexed.
    
###elasticsearch

    gem 'tire'
    gem 'activesearch'

##Configuration

call "search_by" from your model:
      
    search_by [:title, :body, store: [:slug]], if: :its_friday

**IMPORTANT: the first parameter must be either an array, or a symbol.
The second parameter must be a conditions hash.**

the :store option allows you to store that value in the index but it won't be used for search.
You can also add :if or :unless conditions in the same way you would do with ActiveModel callbacks.
If you need virtual options, pass a symbol instead:

    search_by :options_for_search
    
And define an instance method with that name which must return an array with the options, ie:

    def options_for_search
      [:field, :another_field]
    end

## Querying
  
    ActiveSearch.search("some words").first.to_hash["title"]
  
You can access the stored fields with to_hash, so you don't need to fetch the real document.

## Why?

You might wonder why you would like to use ActiveSearch instead of a specific option for your fulltext search index.
ActiveSearch provides an uniform API, which is in itself a drop-in replacement in case you want to move from an engine to another.

## Testing

Run specs with this command:

    bundle exec parallel_rspec spec/

Since different engines define their own version of ActiveSearch, running specs on a single process will break.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
