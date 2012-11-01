module ActiveSearch
  class Result < Hash
    def initialize(result)
      result.to_hash.each do |k,v|
        self[k.to_s] = v unless v.nil?
      end
    end
    
    def attributes
      self
    end
  end
end