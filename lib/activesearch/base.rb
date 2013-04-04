require "active_support/core_ext/class/attribute"

module ActiveSearch
  def self.strip_tags(value)
    case value
    when String
      value.gsub(/<\/?[^>]*>/, '')
    when Hash
      value.each { |k,v| value[k] = strip_tags(value[k]) }
    end
  end
  
  module Base
    def self.included(parent)
      parent.extend ClassMethods
      parent.class_attribute :search_parameters, instance_reader: false
    end
    
    def search_options
      search_parameters.last.is_a?(Hash) ? search_parameters.last : {}
    end
    
    def search_fields
      search_parameters.last.is_a?(Hash) ? search_parameters[0...-1] : search_parameters
    end
    
    def search_parameters
      if self.class.search_parameters.is_a?(Symbol)
        self.send(self.class.search_parameters)
      else
        self.class.search_parameters
      end
    end
    
    module ClassMethods
      def search_by(params, conditions = {})
        after_save    :reindex, conditions
        after_destroy :deindex, conditions
        self.search_parameters = params
      end
      
    end
  end
end