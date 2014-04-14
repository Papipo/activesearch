module ActiveSearch
  module Mongoid
    class Index

      include ::Mongoid::Document

      ## fields ##
      field :original_type, type: String
      field :original_id,   type: Moped::BSON::ObjectId
      field :language,      type: String
      field :locale,        type: String
      field :content,       type: Array
      field :stored,        type: Hash, default: {}
      alias_method :to_hash, :stored

      ## indexes ##
      index({ content: 'text', locale: 1 })
      index({ original_type: 1, original_id: 1, locale: 1 }, unique: true)

      ## methods ##

      def store_language(original)
        self.locale   = original.search_locale
        self.language = FullTextSearchQuery.locale_to_language(self.locale)
      end

      def store_fields(original)
        self.stored = {}

        fields = (original.search_fields + (original.search_options[:store] || [])).uniq

        fields.each do |f|
          content = original.send(f)

          if content.present?
            content = content.to_indexable if content.respond_to?(:to_indexable)
            self.stored[f] = ActiveSearch.strip_tags(content)
          end
        end
      end

      def refresh_content(original)
        self.content = original.to_indexable.values.flatten
      end

      ## class methods ##

      def self.search(query, conditions = {}, options = {})
        query = FullTextSearchQuery.new(collection.name, query, conditions, options)
        query.run
      end

      def self.deindex(original)
        # delete the records in all the locales
        self.where(original_type: original.class.to_s, original_id: original.id).destroy
      end

      def self.reindex(original, fields, options)
        # re-index only in the current locale (unless another locale has been specified)
        locale = original.search_locale

        # find the exact index scoped by the locale or build a new one
        doc = find_or_initialize_by(original_type: original.class.to_s, original_id: original.id, locale: locale)

        doc.store_language(original)
        doc.store_fields(original) #, fields, options)
        doc.refresh_content(original)

        # save it (create or update it)
        doc.save
      end

    end
  end
end