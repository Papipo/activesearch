#encoding: utf-8
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'mongoid'
require 'activesearch/mongoid'

Mongoid.load!("config/mongoid.yml", :test)

class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, localize: true
  field :not_localized
  field :array, type: Array
  def virtual
    "virtual #{not_localized}"
  end
  search_by [:title, :not_localized, :virtual, :array, store: [:title]]
end


describe ActiveSearch::Mongoid do
  before do
    Mongoid.purge!
    I18n.locale = :en
    @localized  = LocalizedMongoidModel.create!(
      title: "<strong>English</strong> English",
      not_localized: "some data"
    )
    I18n.with_locale(:es) do
      @localized.title = "Español Español"
      @localized.save!
    end
  end
  
  it "should be able to find by different locales" do
    ActiveSearch.search("english").first["title"].should == "<strong>English</strong> English"
    I18n.with_locale(:es) do
      ActiveSearch.search("español").first["title"].should == "Español Español"
    end
  end
  
  it "adds all searchable attributes into highlighted hash" do
    found = ActiveSearch.search("english").first
    found['highlighted'].should have_key('title')
    found['highlighted'].should have_key('virtual') 
  end
  
  # Implementation mutates state, is there some reason for this behavior?
  it "actually behaves strange now" do
    search = ActiveSearch.search("english")
    search.first["title"].should == "<strong>English</strong> English"
    search.first["title"].should == "<strong>English</strong> English"    
  end
  
  it "should store localized keywords with tags stripped" do
    ActiveSearch::Mongoid::Model.where(_original_type: "LocalizedMongoidModel", _original_id: @localized.id).first._keywords.should include("en:english", "es:español")
  end
  
  it "should store virtual fields" do
    ActiveSearch::Mongoid::Model.where(_original_type: "LocalizedMongoidModel", _original_id: @localized.id).first._keywords.should include("virtual")
  end
  
  it "handles empty translations" do
    lambda { LocalizedMongoidModel.create!(title: nil, not_localized: "example") }.should_not raise_error
  end
  
  it "handles empty fields" do
    lambda { LocalizedMongoidModel.create!(title: "Example", not_localized: nil) }.should_not raise_error
  end
  
  it "handles nil values in arrays" do
    lambda { LocalizedMongoidModel.create!(title: "Example", not_localized: "example", array: [nil]) }.should_not raise_error
  end
end