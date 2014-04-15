require 'tire'
require "active_support/core_ext"
require "activesearch/base"
require "activesearch/proxy"

module ActiveSearch

  def self.search(text)
    raise 'sorry but it is not implemented'

    Proxy.new(text) do |text|
      Tire.search('_all') do |search|
        search.query do |query|
          query.match("_all", text)
        end
      end.results
    end
  end

  module ElasticSearch
    def self.included(base)
      base.class_eval do
        include ActiveSearch::Base
      end
    end

    def to_indexable
      elastic_properties.keys.inject({_type: self.elastic_type}) do |memo,field|
        memo.merge!(field => self.send(field))
      end
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
      properties = self.elastic_properties

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

    def elastic_properties
      props = {id: {type: 'string'}}

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