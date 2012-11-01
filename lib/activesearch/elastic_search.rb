require "active_support/core_ext"
require "activesearch/elastic_search/proxy"

module ActiveSearch
  
  def self.search(text)
    ElasticSearch::Proxy.new(text)
  end
  
  module ElasticSearch
    def self.included(base)
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    def search_by(*fields)
      options = fields.pop if fields.last.is_a?(Hash)
      include Tire::Model::Search
      include Tire::Model::Callbacks
      
      mapping do
        indexes :type
        indexes :id, as: :original_id
        fields.each { |f| indexes f }
        (Array(options[:store]) - fields).each { |f| indexes f, :index => :no }
      end
    end
  end
end