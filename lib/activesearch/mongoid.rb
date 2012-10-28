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
    
    module ClassMethods
      def search_on(*fields)
        # TODO: Use inheritable class variables, so ActiveSearch::Mongoid::Model can get fields and options from there
        self.class_eval <<-EOV
          after_save do
            fields = #{fields}
            options = fields.pop if fields.last.is_a?(Hash)
            return unless fields.any? { |f| self.send("\#{f}_changed?") }
            ActiveSearch::Mongoid::Model.reindex(self, fields, options)
          end
        EOV
      end
    end
  end
end