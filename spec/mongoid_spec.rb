require 'mongoid'
require 'activesearch/mongoid'

Mongoid.database = Mongo::Connection.new("localhost").db("activesearch_test")

class MongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, type: String
  field :text,  type: String
  field :junk,  type: String
  search_on :title, :text
end

describe ActiveSearch::Mongoid do
  before do
    MongoidModel.delete_all
    @findable = MongoidModel.create!(title: "Findable")
    @quite_findable = MongoidModel.create!(title: "Some title", text: "Findable text")
    MongoidModel.create!(title: "Junk", junk: "Findable junk")
  end
  
  it "should find the expected documents" do
    MongoidModel.fts("findable").to_a.should == [@findable, @quite_findable]
  end
  
  it "should store the proper keywords" do
    @quite_findable._keywords.should == %w{some title findable text}
  end
  
  it "should be chainable" do
    MongoidModel.fts("findable").should respond_to(:where)
  end
end