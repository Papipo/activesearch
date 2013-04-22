module ActiveSearch
  class Result < Hash
    def initialize(result)
      result.to_hash.each do |k,v|
        unless v.nil?
          self[k.to_s] = v.respond_to?(:has_key?) && v.has_key?(I18n.locale.to_s) ? v[I18n.locale.to_s] : v
        end
      end
    end
  end
end