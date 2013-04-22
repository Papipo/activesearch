#encoding: utf-8
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'mongoid'
require 'activesearch/mongoid'

Mongoid.database = Mongo::Connection.new("localhost").db("activesearch_test")

class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, localize: true
  search_by [:title, store: [:title]]
end


describe ActiveSearch::Mongoid do
  before do
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
    I18n.locale = :en
    @localized  = LocalizedMongoidModel.create!(title: "<strong>English</strong> English")
    I18n.with_locale(:es) do
      @localized.title = "Español Español"
      @localized.save!
    end
  end
  
  it "should be able to find by different locales" do
    ActiveSearch.search("english").first["title"]["en"].should == "<strong>English</strong> English"
    I18n.with_locale(:es) do
      ActiveSearch.search("español").first["title"]["es"].should == "Español Español"
    end
  end
  
  it "should store localized keywords with tags stripped" do
    ActiveSearch::Mongoid::Model.where(_original_type: "LocalizedMongoidModel", _original_id: @localized.id).first._keywords.should == ["en:english", "es:español"]
  end
end