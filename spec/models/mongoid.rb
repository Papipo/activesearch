require 'mongoid'
require 'activesearch/mongoid'

Mongoid.database = Mongo::Connection.new("localhost").db("activesearch_test")

class MongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  field :text,  type: String
  field :junk,  type: String
  field :special, type: Boolean, default: false
  search_by [:title, :text, store: [:title, :junk]], unless: :special
end

class AnotherMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  search_by :options_for_search
  
  def options_for_search
    [:title, :text, store: [:title, :virtual]]
  end
  
  def virtual
    "virtual"
  end
end


class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, localize: true
  field :special_type
  search_by [:title, store: [:title]]
end