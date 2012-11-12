module ActiveSearch
  module Base
    def search_by(*params)
      @search_parameters = params
      self.after_save    :reindex, self.search_conditions
      self.after_destroy :deindex, self.search_conditions
    end
    
    def search_options
      search_parameters.last.is_a?(Hash) ? search_parameters.last : {}
    end
    
    def search_conditions
      {}.tap do |conditions|
        conditions.merge!(if: search_options[:if]) if search_options.has_key?(:if)
        conditions.merge!(unless: search_options[:unless]) if search_options.has_key?(:unless)
      end
    end
    
    def search_fields
      search_parameters.last.is_a?(Hash) ? search_parameters[0...-1] : search_parameters
    end
    
    protected
    def search_parameters
      @search_parameters.first.respond_to?(:call) ? @search_parameters.first.call : @search_parameters
    end
  end
end