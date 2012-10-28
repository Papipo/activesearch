#encoding: utf-8
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


class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, localize: true
  search_on :title, store: [:title]
end


describe ActiveSearch::Mongoid do
  before do
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
    I18n.locale = :en
    @findable       = MongoidModel.create!(title: "Findable Findable")
    @quite_findable = MongoidModel.create!(title: "Some title", text: "Findable text")
    @another        = AnotherMongoidModel.create!(title: "Another findable title")
    @junk           = MongoidModel.create!(title: "Junk", junk: "Not Findable junk")
    @localized      = LocalizedMongoidModel.create!(title: "English English")
    I18n.with_locale(:es) do
      @localized.title = "Español Español"
      @localized.save
    end
  end
  
  it "should find the expected documents" do
    ActiveSearch.search("findable").map { |r| r.stored["title"] }.should == ["Findable Findable", "Some title", "Another findable title"]
  end
  
  it "should store the proper keywords" do
    ActiveSearch::Mongoid::Model.where(type: "MongoidModel", original_id: @quite_findable.id).first.keywords.should == %w{some title findable text}
  end
  
  it "should be chainable" do
    ActiveSearch.search("findable").should respond_to(:where)
  end
  
  it "should store the specified fields" do
    ActiveSearch::Mongoid::Model.where(type: "MongoidModel", original_id: @findable.id).first.stored.should == {"title" => "Findable Findable"}
  end
  
  it "should be able to find by different locales" do
    ActiveSearch.search("english").first.stored["title"]["en"].should == "English English"
    I18n.with_locale(:es) do
      ActiveSearch.search("español").first.stored["title"]["es"].should == "Español Español"
    end
  end
  
  it "should store localized keywords" do
    ActiveSearch::Mongoid::Model.where(type: "LocalizedMongoidModel", original_id: @localized.id).first.keywords.should == ["en:english", "es:español"]
  end
end