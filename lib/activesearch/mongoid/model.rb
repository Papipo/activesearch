module ActiveSearch
  module Mongoid
    class Model
      include ::Mongoid::Document
      
      field :_original_type, type: String
      field :_original_id, type: Moped::BSON::ObjectId
      field :_keywords
      field :_stored, type: Hash, default: {}
      alias_method :to_hash, :_stored
      
      index({_keywords: 1})
      index({_original_type: 1, _original_id: 1}, unique: true)
      
      def store_fields(original, fields, options)
        if options && options[:store]
          self._stored = {}
          options[:store].each do |f|
            
            if original.fields[f.to_s] && original.fields[f.to_s].localized?
              self._stored[f] = original.send("#{f}_translations")
            else
              self._stored[f] = original.send(f) if original.send(f).present?
            end
          end
        end
      end
      
      def refresh_keywords(original, fields)
        self._keywords = fields.map do |f|
          
          if original.fields[f.to_s] && original.fields[f.to_s].localized?
            original.send("#{f}_translations").reject { |l, t| t.nil? }.map do |locale, translation|
              translation.downcase.split.map { |word| "#{locale}:#{word}"}
            end.flatten
          else
            [original.try(f)].flatten.reject(&:nil?).map(&:downcase).map(&:split).flatten
          end
        end.flatten

        
        self._keywords.map! { |k| ActiveSearch.strip_tags(k) }
        self._keywords.uniq!
      end
      
      def self.deindex(original)
        ActiveSearch::Mongoid::Model.where(_original_type: original.class.to_s, _original_id: original.id).destroy
      end
      
      def self.reindex(original, fields, options)
        doc = find_or_initialize_by(_original_type: original.class.to_s, _original_id: original.id)
        doc.store_fields(original, fields, options)
        doc.refresh_keywords(original, fields)
        doc.save
      end
    end
  end
end