require 'tire'
require 'activesearch/elastic_search'

Tire.configure { logger File.join(File.dirname(__FILE__), '..', '..', 'log', 'elasticsearch.log'), :level => 'debug' }

module ElasticSearchRefresh
  
  def save
    super.tap { tire.index.refresh }
  end
  
  def destroy
    super.tap { tire.index.refresh; sleep(1) }
  end
end

class ElasticSearchModel < ActiveMimic
  include ActiveSearch::ElasticSearch
  include ElasticSearchRefresh
  
  attribute :title
  attribute :text
  attribute :junk
  
  search_by :title, :text, store: [:title, :junk]

end

class AnotherElasticSearchModel < ActiveMimic
  include ActiveSearch::ElasticSearch
  include ElasticSearchRefresh
  
  attribute :title, type: String
  search_by :title, store: [:title]
end