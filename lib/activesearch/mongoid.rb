require 'activesearch/base'
require 'activesearch/proxy'
require 'activesearch/mongoid/index'

module ActiveSearch

  def self.search(text, conditions = {}, options = {})
    # TODO: locale as an option (use I18n.locale by default)
    # Proxy.new(text, conditions, options) do |text, conditions|
    #   text = text.downcase.split(/\s+/)
    #   conditions.keys.each { |k| conditions["_stored.#{k}"] = conditions.delete(k) }
    #   conditions.merge!(:_keywords.in => text + text.map { |word| "#{I18n.locale}:#{word}"})
    #   Mongoid::Model.where(conditions)
    # end

    locale = options[:locale] || I18n.locale
    conditions[:locale] ||= locale

    Proxy.new(text, conditions, options) do |text, conditions|
      ActiveSearch::Mongoid::Index.search(text, conditions)
    end
  end

  module Mongoid
    def self.included(base)
      base.class_eval do
        include Base
      end
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