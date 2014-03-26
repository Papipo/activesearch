module SetupEngine

  def self.setup(name)
    # 1. set up the engine (connection)
    case name
    when :algolia         then setup_algolia
    when :mongoid         then setup_mongoid
    when :elastic_search  then setup_elastic_search
    end

    # 2. load the test models depending on the engine
    require File.join(File.dirname(__FILE__), '..', 'models', "#{name}.rb")
  end

  protected

  def self.setup_algolia
    require 'yaml'
    require 'activesearch/algolia'

    YAML.load_file(File.dirname(__FILE__) + '/../../config/algolia.yml').tap do |config|
      ActiveSearch::Algolia::Client.configure(config["api_key"], config["app_id"])
    end

    ActiveSearch::Algolia::Client.new.delete_index
  end

  def self.setup_mongoid
    require 'mongoid'

    Mongoid.configure do |config|
      config.sessions = {
        :default => {
          :hosts => ["localhost"],
          :database => "activesearch_test"
        }
      }
    end

    require 'activesearch/mongoid'

    ActiveSearch::Mongoid::Index.create_indexes

    DatabaseCleaner.clean
  end

  def self.elastic_search
    # TODO

    # Tire::Configuration.client.delete "#{Tire::Configuration.url}/_all"
  end

end