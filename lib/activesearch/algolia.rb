require "activesearch/algolia/client"
require "activesearch/base"
require "activesearch/proxy"
require "girl_friday/store/mongo"

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
    Queue = ::GirlFriday::WorkQueue.new('activesearch_algolia', store: GirlFriday::Store::Mongo) do |msg|
      begin
        case msg[:task]
        when :reindex
          ::ActiveSearch::Algolia::Client.new.save(msg[:id], msg[:doc])
        when :deindex
          ::ActiveSearch::Algolia::Client.new.delete(msg[:id])
        end
      rescue
        ActiveSearch::Algolia::Queue.push(msg.merge!(retries: msg[:retries].to_i + 1)) unless msg[:retries].to_i >= 3
      end
    end
      
    def self.included(base)
      base.class_eval do
        include Base
      end
    end
    
    protected
    def reindex
      Queue.push(task: :reindex, id: indexable_id, doc: self.to_indexable)
    end
    
    def deindex
      Queue.push(task: :deindex, id: indexable_id)
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