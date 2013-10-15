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
  
  context "retry on errors" do
    before do
      times_called = 0
      @instance = AlgoliaModel.new(title: "Example")
      ActiveSearch::Algolia::Client.should_receive(:put).exactly(3).times.and_return do
        times_called += 1
        raise Errno::ECONNRESET if times_called <= 2
      end
    end
    
    subject { -> { @instance.save } }
    
    it { should_not raise_error }
  end
end