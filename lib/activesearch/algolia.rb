require "activesearch/algolia/client"
require "activesearch/algolia/worker"
require "activesearch/base"
require "activesearch/proxy"

module ActiveSearch

  def self.search(text, conditions = {}, options = {})
    locale = options[:locale] || I18n.locale
    conditions[:locale] ||= locale

    Proxy.new(text, conditions, options) do |text, conditions|
      Algolia::Client.new.query(text, tags: conditions_to_tags(conditions))["hits"].map! do |hit|
        if hit["_tags"]
          hit["_tags"].each do |tag|
            # preserve other ":" characters
            _segments = tag.split(':')

            unless _segments.empty? || _segments[1..-1].empty?
              hit[_segments.first] = _segments[1..-1].join(':')
            end
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
      Worker.new.async.perform(task: :reindex, id: "#{indexable_id}_#{search_locale}", doc: to_indexable)
    end

    def deindex
      Worker.new.async.perform(task: :deindex, id: self.id, type: self.class.to_s)
    end

    def to_indexable
      {}.tap do |doc|
        _locale = search_locale

        search_fields.each do |field|
          if content = send(field)
            doc[field.to_s] = if content.is_a?(Hash) && content.has_key?(_locale)
              ActiveSearch.strip_tags(content[_locale])
            else
              ActiveSearch.strip_tags(content)
            end
          end
        end

        (Array(search_options[:store]) - search_fields).each do |field|
          doc["_tags"] ||= []
          doc["_tags"] << "#{field}:#{self.send(field)}"
        end
        doc["_tags"] << "locale:#{_locale}"
        doc["_tags"] << "original_type:#{self.class.to_s}"
        doc["_tags"] << "original_id:#{self.id}"
      end
    end
  end
end