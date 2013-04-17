require 'activesearch/algolia'

module AlgoliaId
  def algolia_id
    "#{self.class.to_s}_#{self.id}"
  end
end

class AlgoliaModel < ActiveMimic
  include ActiveSearch::Algolia
  include AlgoliaId
  
  attribute :title
  attribute :text
  attribute :junk
  attribute :special, default: false
  
  search_by [:title, :text, store: [:title, :junk]], if: lambda { !self.special }

end

class AnotherAlgoliaModel < ActiveMimic
  include ActiveSearch::Algolia
  include AlgoliaId
  
  attribute :title, type: String
  search_by [:title, store: [:title, :virtual]]
  
  def virtual
    "virtual"
  end
end