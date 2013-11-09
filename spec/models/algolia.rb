require 'activesearch/algolia'

class AlgoliaModel < ActiveMimic
  include ActiveSearch::Algolia
  
  attribute :title
  attribute :text
  attribute :junk
  attribute :special, default: false
  attribute :scope_id, type: Integer
  attribute :tags, type: Array
  localized_attribute :color
  
  search_by [:title, :text, :tags, :color, store: [:title, :junk, :scope_id]], if: lambda { !self.special }

end

class AnotherAlgoliaModel < ActiveMimic
  include ActiveSearch::Algolia
  
  attribute :title, type: String
  attribute :scope_id, type: Integer
  localized_attribute :color
  search_by [:title, store: [:title, :virtual, :scope_id, :color]]
  
  def virtual
    "virtual"
  end
end