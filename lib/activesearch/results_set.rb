module ActiveSearch
  class ResultsSet

    attr_reader :results, :total_entries, :total_pages, :page, :per_page

    def initialize(results, page = nil, per_page = nil)
      @results  = results
      @page     = page || 0
      @per_page = per_page || 10
    end

    def define_parser(&block)
      @parser = block
    end

    def parse(result)
      result
    end

  end
end