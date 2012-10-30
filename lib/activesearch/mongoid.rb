require 'activesearch/mongoid/model'

module ActiveSearch
  
  # TODO: Wrap this so all engines behave consistently
  def self.search(text)
    Mongoid::Model.where(:keywords.in => text.split + text.split.map { |word| "#{I18n.locale}:#{word}"})
  end
  
  module Mongoid
    def self.included(base)
      base.extend ClassMethods
    end
    
    protected
    def reindex
      ActiveSearch::Mongoid::Model.reindex(self, self.class.search_fields, self.class.search_options)
    end
    
    def deindex
      ActiveSearch::Mongoid::Model.deindex(self)
    end
    
    module ClassMethods
      def search_options
        @search_options
      end
      
      def search_fields
        @search_fields
      end
      
      def search_on(*fields)
        @search_options = fields.pop if fields.last.is_a?(Hash)
        @search_fields  = fields
        self.after_save :reindex
        self.before_destroy :deindex
      end
    end
  end
end