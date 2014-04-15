require "activesearch/result"

module ActiveSearch
  class Proxy
    include Enumerable

    extend Forwardable

    def_delegators :@results_set, :total_pages, :total_entries, :per_page, :page

    def initialize(results_set, text, options)
      @results_set    = results_set
      @text           = text
      @options        = options
    end

    def each(&block)
      @results_set.results.map do |result|
        _result = @results_set.parse(result)
        block.call(Result.new(_result, @text, @options))
      end
    end

  end
end