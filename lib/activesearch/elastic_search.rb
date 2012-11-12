require 'tire'
require "active_support/core_ext"
require "activesearch/base"
require "activesearch/elastic_search/proxy"

module ActiveSearch
  
  def self.search(text)
    ElasticSearch::Proxy.new(text)
  end
  
  module ElasticSearch
    def self.included(base)
      base.extend Base
      base.extend ClassMethods
    end
    
    def to_indexable
      self.attributes.merge(_type: self.elastic_type)
    end
    
    protected
    def elastic_type
      @elastic_type ||= self.type.gsub!(/(.)([A-Z])/,'\1_\2').downcase
    end
    
    def elastic_index(&block)
      Tire.index(elastic_type, &block)
    end
    
    def reindex
      doc = self.to_indexable
      properties = self.class.elastic_properties
      
      elastic_index do
        unless exists?
          create({ mappings: { doc[:_type] => {properties: properties}}})
        end
        store doc
      end
    end
    
    def deindex
      doc = self.to_indexable
      elastic_index do
        remove doc
      end
    end
    
    module ClassMethods
      def elastic_properties
        props = {}
        
        search_fields.each_with_object(props) do |field,hash|
          hash[field] = {type: 'string'}
        end
        
        (Array(search_options[:store]) - search_fields).each_with_object(props) do |field,hash|
          hash[field] = {type: 'string', :index => :no}
        end
        
        props
      end
    end
  end
end