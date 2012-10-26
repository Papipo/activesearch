require 'mongoid'
require 'activesearch/mongoid'

Mongoid.database = Mongo::Connection.new("localhost").db("activesearch_test")

class MongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  field :text,  type: String
  field :junk,  type: String
  search_on :title, :text, store: [:title]
end

class AnotherMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  search_on :title, :text, store: [:title]
end

describe ActiveSearch::Mongoid do
  before do
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
    
    @findable = MongoidModel.create!(title: "Findable")
    @quite_findable = MongoidModel.create!(title: "Some title", text: "Findable text")
    @another = AnotherMongoidModel.create!(title: "Another findable title")
    @junk = MongoidModel.create!(title: "Junk", junk: "Findable junk")
  end
  
  it "should find the expected documents" do
    ActiveSearch.search("findable").map { |r| r.stored["title"] }.should == ["Findable", "Some title", "Another findable title"]
  end
  
  it "should store the proper keywords" do
    ActiveSearch::Mongoid::Model.where(type: "MongoidModel", original_id: @quite_findable.id).first.keywords.should == %w{some title findable text}
  end
  
  it "should be chainable" do
    ActiveSearch.search("findable").should respond_to(:where)
  end
  
  it "should store the specified fields" do
    ActiveSearch::Mongoid::Model.where(type: "MongoidModel", original_id: @findable.id).first.stored.should == {"title" => "Findable"}
  end
end