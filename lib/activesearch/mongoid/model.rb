module ActiveSearch
  module Mongoid
    class Model
      include ::Mongoid::Document
      
      field :type, type: String
      field :original_id, type: BSON::ObjectId
      field :keywords
      field :stored, type: Hash, default: {}
      
      index :keywords
      index [:type, :original_id], unique: true
      
      def store_fields(original, fields, options)
        if options && options[:store]
          options[:store].each do |f|
            self.stored[f] = original[f] if original.send("#{f}_changed?")
          end
        end
      end
      
      def refresh_keywords(original, fields)
        self.keywords = fields.select { |f| original.fields[f.to_s]  }.inject([]) do |memo,f|
          
          if original.fields[f.to_s].localized?
            memo += original.send("#{f}_translations").map do |locale,translation|
              translation.downcase.split.map { |word| "#{locale}:#{word}"}
            end.flatten
          else
            original[f] ? memo += original[f].downcase.split : memo
          end
        end
        self.keywords.uniq!
      end
      
      def self.reindex(original, fields, options)
        doc = self.find_or_initialize_by(type: original.class.to_s, original_id: original.id)
        doc.store_fields(original, fields, options)
        doc.refresh_keywords(original, fields)
        doc.save
      end
    end
  end
end