#encoding: utf-8
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'activesearch/algolia'
require_relative 'models/algolia'

YAML.load_file(File.dirname(__FILE__) + '/../config/algolia.yml').tap do |config|
  ActiveSearch::Algolia::Client.configure(config["api_key"], config["app_id"])
end

describe ActiveSearch::Algolia do
  before do
    ActiveSearch::Algolia::Client.new.delete_index
  end
  
  context "errors on save" do
    before do
      @instance = AlgoliaModel.new(title: "Example")
      @instance.should_receive(:touch).once
      ActiveSearch::Algolia::Client.any_instance.stub(:save).and_raise(Errno::ECONNRESET)
    end
    
    subject { -> { @instance.save } }
    
    it { should_not raise_error }
  end
end