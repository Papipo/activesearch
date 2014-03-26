require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

require 'rspec'

require 'activesearch/base'
require 'active_model'
require 'active_attr'
require 'sucker_punch'
require 'sucker_punch/testing/inline'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

  require 'database_cleaner'
  require 'database_cleaner/mongoid/truncation'

  config.backtrace_clean_patterns = [
    /\/lib\d*\/ruby\//,
    /bin\//,
    /gems/,
    /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]

  config.before(:suite) do
    DatabaseCleaner['mongoid'].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    # ElasticSearch engine
    # Tire::Configuration.client.delete "#{Tire::Configuration.url}/_all"

    # Algolia engine
    # ActiveSearch::Algolia::Client.new.delete_index

    # Mongoid engine
    # DatabaseCleaner.clean

    ::I18n.locale = 'en'
  end
end
