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

Add this to your model:
      
    search_by :title, :body, store: [:slug]
    
the :store option allows you to retrieve that value but it won't be used for search.

## Querying
  
    ActiveSearch.search("some words").first.to_hash["title"]
  
You can access the stored fields with to_hash, so you don't need to fetch the real document.

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
