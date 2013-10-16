require "activesearch/algolia/client"
require "activesearch/algolia/worker"
require "activesearch/base"
require "activesearch/proxy"

module ActiveSearch
  def self.search(text, conditions = {})
    Proxy.new(text, conditions) do |text, conditions|
      options = {}
      tags = conditions_to_tags(conditions)
      options.merge!(tags: tags) if tags != ""
      Algolia::Client.new.query(text, options)["hits"].map! do |hit|
        if hit["_tags"]
          hit["_tags"].each do |tag|
            k, v = tag.split(':')
            hit[k] = v
          end
          hit.delete("_tags")
        end
        hit
      end
    end
  end
  
  protected
  def self.conditions_to_tags(conditions)
    conditions.map { |c| c.join(':') }.join(',')
  end
  
  module Algolia      
    def self.included(base)
      base.class_eval do
        include Base
      end
    end
    
    protected
    def reindex
      Worker.new.async.perform(task: :reindex, id: indexable_id, doc: self.to_indexable)
    end
    
    def deindex
      Worker.new.async.perform(task: :deindex, id: indexable_id)
    end
    
    def to_indexable
      doc = {}
      search_fields.each do |field|
        doc[field.to_s] = attributes[field.to_s] if attributes[field.to_s]
      end
      
      (Array(search_options[:store]) - search_fields).each do |field|
        doc["_tags"] ||= []
        doc["_tags"] << "#{field}:#{self.send(field)}"
      end
      doc
    end
  end
end