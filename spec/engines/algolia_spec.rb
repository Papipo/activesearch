#encoding: utf-8
require 'spec_helper'

describe 'ActiveSearch::Algolia' do

  before(:all) do
    SetupEngine.setup(:algolia)

    # can not use the rspec let method
    @model          = AlgoliaModel
    @another_model  = AnotherAlgoliaModel
  end

  include_examples 'an engine'

  context 'retry on errors' do

    before do
      times_called = 0
      @instance = AlgoliaModel.new(title: 'Example')
      ActiveSearch::Algolia::Client.should_receive(:put).exactly(3).times.and_return do
        times_called += 1
        raise Errno::ECONNRESET if times_called <= 2
      end
    end

    subject { -> { @instance.save } }

    it { should_not raise_error }
  end

end