module ActiveSearch
  module Mongoid
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def search_on(*fields)
        field :_keywords, type: Array
        index :_keywords
        
        before_save do
          self._keywords = []
          
          fields.each do |f|
            self._keywords = self._keywords | self[f].downcase.split if self[f]
          end
        end
      end
      
      def fts(query)
        all_in(_keywords: query.split)
      end
    end
  end
end