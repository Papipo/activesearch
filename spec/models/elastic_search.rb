require 'activesearch/elastic_search'

module ElasticSearchRefresh
  
  def save
    super.tap { Tire.index('_all') { refresh }}
  end
  
  def destroy
    super.tap { Tire.index('_all') { refresh }}
  end
end

class ElasticSearchModel < ActiveMimic
  include ActiveSearch::ElasticSearch
  include ElasticSearchRefresh
  
  attribute :title
  attribute :text
  attribute :junk
  attribute :special, default: false
  attribute :tags, type: Array
  
  search_by [:title, :text, :tags, store: [:title, :junk]], if: lambda { !self.special }

end

class AnotherElasticSearchModel < ActiveMimic
  include ActiveSearch::ElasticSearch
  include ElasticSearchRefresh
  
  attribute :title, type: String
  search_by [:title, store: [:title, :virtual]]
  
  def virtual
    "virtual"
  end
end