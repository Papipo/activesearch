#encoding: utf-8
require 'spec_helper'

describe 'ActiveSearch::Mongoid' do

  before(:all) do
    SetupEngine.setup(:mongoid)

    # can not use the rspec let method
    @model          = MongoidModel
    @another_model  = AnotherMongoidModel
  end

  include_examples 'an engine'

  describe 'localized content' do

    before(:all) do
      @localized = LocalizedMongoidModel.create!(title: "<strong>English</strong> English")
      I18n.with_locale(:es) do
        @localized.title = "Español Español"
        @localized.save!
      end
    end

    it "should be able to find by different locales" do
      ActiveSearch.search("english").first["title"].should == "English English"
      I18n.with_locale(:es) do
        ActiveSearch.search("español").first["title"].should == "Español Español"
      end
    end

    it "finds by a different locale" do
      ActiveSearch.search("español", {}, { locale: 'es'}).first["title"].should == "Español Español"
    end

    it "should store content with tags stripped" do
      index = ActiveSearch::Mongoid::Index.where(original_type: "LocalizedMongoidModel", original_id: @localized.id, locale: 'en')
      index.first.content.should == ["English English"]
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

end