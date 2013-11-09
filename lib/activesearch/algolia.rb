require "activesearch/algolia/client"
require "activesearch/algolia/worker"
require "activesearch/base"
require "activesearch/proxy"

module ActiveSearch
  def self.search(text, conditions = {})
    Proxy.new(text, conditions) do |text, conditions|
      Algolia::Client.new.query(text, tags: conditions_to_tags(conditions))["hits"].map! do |hit|
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
    conditions.merge(locale: I18n.locale).map { |c| c.join(':') }.join(',')
  end
  
  module Algolia
    def self.included(base)
      base.class_eval do
        include Base
      end
    end
    
    protected
    def reindex
      Worker.new.async.perform(task: :reindex, id: "#{indexable_id}_#{I18n.locale}", doc: to_indexable)
    end
    
    def deindex
      Worker.new.async.perform(task: :deindex, id: indexable_id)
    end
    
    def to_indexable
      doc = {}
      search_fields.each do |field|
        if send(field)
          doc[field.to_s] = if send(field).is_a?(Hash) && send(field).has_key?(I18n.locale.to_s)
            ActiveSearch.strip_tags(send(field)[I18n.locale.to_s])
          else
            ActiveSearch.strip_tags(send(field))
          end
        end
      end
      
      (Array(search_options[:store]) - search_fields).each do |field|
        doc["_tags"] ||= []
        doc["_tags"] << "#{field}:#{self.send(field)}"
      end
      doc["_tags"] << "locale:#{I18n.locale}"
      doc["_tags"] << "original_id:#{indexable_id}"
      doc
    end
  end
end