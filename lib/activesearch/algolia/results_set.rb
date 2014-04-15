module ActiveSearch
  module Algolia
    class ResultsSet < ActiveSearch::ResultsSet

      def initialize(results, page = nil, per_page = nil)
        super

        @results        = results['hits']
        @total_entries  = results['nbHits']
        @total_pages    = results['hitsPerPage']
      end

      def parse(result)
        if result['_tags']
          result['_tags'].each do |tag|
            # preserve other ":" characters
            _segments = tag.split(':')

            unless _segments.empty? || _segments[1..-1].empty?
              result[_segments.first] = _segments[1..-1].join(':')
            end
          end
          result.delete("_tags")
        end
        result
      end

    end
  end
end