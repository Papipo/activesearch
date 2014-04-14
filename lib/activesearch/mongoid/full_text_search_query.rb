module ActiveSearch
  module Mongoid
    class FullTextSearchQuery

      attr_reader :results

      def initialize(name, query, conditions, options)
        @name     = name
        @query    = query
        @filter   = prepare_filter(conditions)
        @options  = options
        @language = self.class.locale_to_language(conditions[:locale] || I18n.locale)
      end

      def run
        @results = session.command({
          'text'      => @name,
          'search'    => @query,
          'language'  => @language,
          'filter'    => @filter
        })

        if @results.has_key?('results')
          sanitize_results
        else
          []
        end
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

      def sanitize_results
        page, per_page = @options[:page] || 0, @options[:per_page] || 10
        included  = ((page * per_page)..((page + 1) * per_page - 1))
        _results  = []

        # manual pagination since it is not natively supported by MongoDB
        @results['results'].each_with_index do |result, index|
          if included === index
            _results << result['obj']['stored'].merge(result['obj'].slice('locale', 'original_type', 'original_id'))
          end
        end

        @results = _results
      end

    end
  end
end