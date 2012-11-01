require "activesearch/result"

module ActiveSearch
  module ElasticSearch
    class Proxy
      include Enumerable
      
      def initialize(text)
        @text = text
      end
      
      def each(&block)
        search.results.each { |result| block.call(Result.new(result)) }
      end
      
      protected
      def search
        @search ||= Tire.search('_all') do |search|
          search.query do |query|
            query.text("_all", @text)
          end
        end
      end
    end
  end
end