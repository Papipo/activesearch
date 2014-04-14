require 'activesearch/base'
require 'activesearch/proxy'
require 'activesearch/mongoid/full_text_search_query'
require 'activesearch/mongoid/index'

module ActiveSearch

  def self.search(text, conditions = {}, options = {})
    locale = options[:locale] || I18n.locale
    conditions[:locale] ||= locale

    Proxy.new(text, conditions, options) do |text, conditions|
      ActiveSearch::Mongoid::Index.search(text, conditions, options)
    end
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