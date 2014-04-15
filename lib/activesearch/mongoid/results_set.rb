module ActiveSearch
  module Mongoid
    class ResultsSet < ActiveSearch::ResultsSet

      def initialize(results, page = nil, per_page = nil)
        super

        @results          = results.has_key?('results') ? results['results'] : []
        @total_entries    = results.size
        @total_pages      = @total_entries / @per_page

        self.paginate if @total_entries > 0
      end

      protected

      def index_range
        ((@page * @per_page)..((@page + 1) * @per_page - 1))
      end

      def paginate
        _results  = []

        # manual pagination since it is not natively supported by MongoDB
        @results.each_with_index do |result, index|
          if index_range === index
            _results << result['obj']['stored'].merge(result['obj'].slice('locale', 'original_type', 'original_id'))
          end
        end

        @results = _results
      end

    end
  end
end