require "activesearch/result"

module ActiveSearch
  class Proxy
    include Enumerable
    
    def initialize(text, &implementation)
      @text = text
      @implementation = implementation
    end
    
    def each(&block)
      @implementation.call(@text).each { |result| block.call(Result.new(result)) }
    end
  end
end