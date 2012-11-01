require 'mongoid'
require 'activesearch/mongoid'

Mongoid.database = Mongo::Connection.new("localhost").db("activesearch_test")

class MongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  field :text,  type: String
  field :junk,  type: String
  search_by :title, :text, store: [:title, :junk]
end

class AnotherMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  search_by :title, :text, store: [:title]
end


class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, localize: true
  search_by :title, store: [:title]
end