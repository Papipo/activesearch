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
      include Tire::Model::Search
      
      options = fields.last.is_a?(Hash) ? fields.pop : {}
      conditions = { if: options.delete(:if), unless: options.delete(:unless) }
      
      mapping do
        indexes :type
        indexes :id, as: :original_id
        fields.each { |f| indexes f }
        (Array(options[:store]) - fields).each { |f| indexes f, :index => :no }
      end
      
      # Partially taken from Tire::Model::Callbacks
      
      if respond_to?(:after_save) && respond_to?(:after_destroy)
        after_save    lambda { tire.update_index }, conditions
        after_destroy lambda { tire.update_index }, conditions
      end

      if respond_to?(:before_destroy) && !instance_methods.map(&:to_sym).include?(:destroyed?)
        before_destroy { @destroyed = true }
        class_eval { def destroyed?; !!@destroyed; end; }
      end
    end
  end
end