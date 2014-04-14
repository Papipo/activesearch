class MongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid

  field :title,     type: String
  field :text,      type: String
  field :junk,      type: String
  field :special,   type: Boolean, default: false
  field :scope_id,  type: Integer
  field :color,     type: String, localize: true
  field :tags,      type: Array

  search_by [:title, :text, :tags, :color, store: [:title, :junk, :scope_id]], unless: :special?
end

class AnotherMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid

  field :title, type: String
  field :scope_id, type: Integer
  field :color, localize: true
  search_by :options_for_search

  def options_for_search
    [:title, store: [:title, :virtual, :scope_id, :color]]
  end

  def virtual
    Struct.new(:to_indexable).new('virtual')
  end
end

class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid

  field :title, localize: true
  field :special_type
  search_by [:title, store: [:title]]
end