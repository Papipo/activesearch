module ActiveSearch
  module Mongoid
    class FullTextSearchQuery

      def initialize(name, query, conditions, options)
        @name     = name
        @query    = query
        @filter   = prepare_filter(conditions)
        @options  = options
        @language = self.class.locale_to_language(conditions[:locale] || I18n.locale)
      end

      def run
        results = session.command({
          'text'      => @name,
          'search'    => @query,
          'language'  => @language,
          'filter'    => @filter
        })

        ResultsSet.new(results, @options[:page], @options[:per_page])
      end

      def session
        ::Mongoid.session('default')
      end

      def self.locale_to_language(locale)
        {
          dk: 'danish',
          nl: 'dutch',
          en: 'english',
          fi: 'finnish',
          fr: 'french',
          de: 'german',
          hu: 'hungarian',
          it: 'italian',
          nb: 'norwegian',
          br: 'portuguese',
          pt: 'portuguese',
          ro: 'romanian',
          ru: 'russian',
          es: 'spanish',
          se: 'swedish',
          tr: 'turkish'
        }[locale.to_sym] || 'english'
      end

      protected

      def prepare_filter(conditions)
        {}.tap do |filter|
          conditions.each do |key, value|
            if key == :locale
              filter['locale'] = value.to_s
            else
              filter["stored.#{key}"] = value
            end
          end
        end
      end

    end
  end
end