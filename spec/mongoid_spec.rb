#encoding: utf-8
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'mongoid'
require 'activesearch/mongoid'

Mongoid.load!("config/mongoid.yml", :test)

class LocalizedMongoidModel
  include Mongoid::Document
  include ActiveSearch::Mongoid
  
  field :title, localize: true
  search_by [:title, store: [:title]]
end


describe ActiveSearch::Mongoid do
  before do
    Mongoid.purge!
    I18n.locale = :en
    @localized  = LocalizedMongoidModel.create!(title: "<strong>English</strong> English")
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
  
  it "should store localized keywords with tags stripped" do
    ActiveSearch::Mongoid::Model.where(_original_type: "LocalizedMongoidModel", _original_id: @localized.id).first._keywords.should == ["en:english", "es:español"]
  end
end