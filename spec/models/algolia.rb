require 'activesearch/algolia'

class AlgoliaModel < ActiveMimic
  include ActiveSearch::Algolia
  
  attribute :title
  attribute :text
  attribute :junk
  attribute :special, default: false
  
  search_by [:title, :text, store: [:title, :junk]], if: lambda { !self.special }

end

class AnotherAlgoliaModel < ActiveMimic
  include ActiveSearch::Algolia
  
  attribute :title, type: String
  search_by [:title, store: [:title, :virtual]]
  
  def virtual
    "virtual"
  end
end