require "activesearch/result"

module ActiveSearch
  class Proxy
    include Enumerable

    def initialize(text, conditions, options = {}, &implementation)
      @text           = text
      @conditions     = conditions
      @options        = options
      @implementation = implementation
    end

    def each(&block)
      @implementation.call(@text, @conditions).each do |result|
        block.call(Result.new(result, @text, @options))
      end
    end
  end
end