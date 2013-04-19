require "activesearch/result"

module ActiveSearch
  class Proxy
    include Enumerable
    
    def initialize(text, conditions, &implementation)
      @text = text
      @conditions = conditions
      @implementation = implementation
    end
    
    def each(&block)
      @implementation.call(@text, @conditions).each { |result| block.call(Result.new(result)) }
    end
  end
end