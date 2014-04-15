require 'activesearch/base'
require 'activesearch/results_set'
require 'activesearch/proxy'

require 'activesearch/algolia/client'
require 'activesearch/algolia/results_set'
require 'activesearch/algolia/worker'

module ActiveSearch

  def self.search(text, conditions = {}, options = {})
    locale = options[:locale] || I18n.locale
    conditions[:locale] ||= locale

    results_set = Algolia::Client.new.query_text(text, { tags: conditions_to_tags(conditions) }, options)

    Proxy.new(results_set, text, options)
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

    def to_indexable(depth = 0)
      {}.tap do |doc|
        _locale = search_locale

        search_fields.each do |field|
          if content = send(field)
            doc[field.to_s] = if content.is_a?(Hash) && content.has_key?(_locale)
              ActiveSearch.strip_tags(content[_locale])
            elsif content && content.respond_to?(:to_indexable)
              ActiveSearch.strip_tags(content.to_indexable(depth + 1))
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