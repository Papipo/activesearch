require 'activesearch/base'
require 'activesearch/results_set'
require 'activesearch/proxy'

require 'activesearch/mongoid/results_set'
require 'activesearch/mongoid/full_text_search_query'
require 'activesearch/mongoid/index'

module ActiveSearch

  def self.search(text, conditions = {}, options = {})
    conditions.symbolize_keys!
    options.symbolize_keys!

    clean_locale(conditions, options)

    results_set = ActiveSearch::Mongoid::Index.search(text, conditions, options)

    Proxy.new(results_set, text, options)
  end

  protected

  def self.clean_locale(conditions, options)
    locale = options[:locale] || I18n.locale
    conditions[:locale] ||= locale

    conditions.delete(:locale) if options[:locale] == false
  end

  module Mongoid
    def self.included(base)
      base.class_eval do
        include Base
      end
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
      end
    end

    protected

    def reindex
      ActiveSearch::Mongoid::Index.reindex(self, self.search_fields, self.search_options)
    end

    def deindex
      ActiveSearch::Mongoid::Index.deindex(self)
    end
  end
end