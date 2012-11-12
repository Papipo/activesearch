require 'activesearch/base'
require 'activesearch/mongoid/model'

module ActiveSearch
  
  # TODO: Wrap this so all engines behave consistently
  def self.search(text)
    text = text.split(/\s+/)
    Mongoid::Model.where(:_keywords.in => text + text.map { |word| "#{I18n.locale}:#{word}"})
  end
  
  module Mongoid
    def self.included(base)
      base.extend Base
    end
    
    protected
    def reindex
      ActiveSearch::Mongoid::Model.reindex(self, self.class.search_fields, self.class.search_options)
    end
    
    def deindex
      ActiveSearch::Mongoid::Model.deindex(self)
    end
  end
end