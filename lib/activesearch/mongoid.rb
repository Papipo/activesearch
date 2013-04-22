require 'activesearch/base'
require 'activesearch/proxy'
require 'activesearch/mongoid/model'

module ActiveSearch
  
  def self.search(text, conditions = {})
    Proxy.new(text, conditions) do |text, conditions|
      text = text.split(/\s+/)
      conditions.keys.each { |k| conditions["_stored.#{k}"] = conditions.delete(k) }
      conditions.merge!(:_keywords.in => text + text.map { |word| "#{I18n.locale}:#{word}"})
      Mongoid::Model.where(conditions)
    end
  end
  
  module Mongoid
    def self.included(base)
      base.class_eval do
        include Base
      end
    end
    
    protected
    def reindex
      ActiveSearch::Mongoid::Model.reindex(self, self.search_fields, self.search_options)
    end
    
    def deindex
      ActiveSearch::Mongoid::Model.deindex(self)
    end
  end
end