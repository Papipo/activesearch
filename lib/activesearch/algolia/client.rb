require "httparty"
require "active_support/core_ext/object/to_json"

module ActiveSearch::Algolia
  class Client
    include HTTParty
    # debug_output $stdout
    base_uri "https://apieu1.algolia.com/1/indexes/activesearch"

    def self.configure(api_key, app_id)
      headers({
        "X-Algolia-API-Key" => api_key,
        "X-Algolia-Application-Id" => app_id,
        "Content-Type" => "application/json; charset=utf-8"
      })
    end

    def delete_index
      self.class.delete("")
    end

    def delete(id)
      self.class.delete("/#{id}")
    end

    def save(id, object)
      self.class.put("/#{id}", body: object.to_json)
    end

    def query(text)
      self.class.get("", query: {query: text})
    end
  end
end