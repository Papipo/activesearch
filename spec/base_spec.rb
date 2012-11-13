require 'activesearch/base'

describe ActiveSearch::Base do
  before do
    @klass = Class.new do
      extend ActiveSearch::Base
      
      def self.after_save(*args); end
      def self.after_destroy(*args); end
      
    end
  end
  
  context "search_by" do
    let(:call_search_by) do
      @klass.class_eval do
        search_by :field, if: :something_happens, unless: :its_friday
      end
    end
    
    it "should rely on after_save and after_destroy callbacks passing conditions" do
      @klass.should_receive(:after_save).with(:reindex, if: :something_happens, unless: :its_friday)
      @klass.should_receive(:after_destroy).with(:deindex, if: :something_happens, unless: :its_friday)
      call_search_by
    end
    
    it "should store the parameters in search_parameters" do
      call_search_by
      @klass.send(:search_parameters).should == [:field, {if: :something_happens, unless: :its_friday}]
    end
  end
  
  context "utility methods with options" do
    before do
      @klass.stub(:search_parameters).and_return([:field, store: [:another_field]])
    end
    
    it "search_options should return the hash at the end of the parameters" do
      @klass.search_options.should == {store: [:another_field]}
    end
    
    it "search_fields should return all parameters except the options" do
      @klass.search_fields.should == [:field]
    end
  end
  
  context "search_by with dynamic parameters" do
    before do
      @klass.class_eval do
        def self.options_for_search
          [:somefield]
        end
        
        search_by lambda { options_for_search }
      end
    end
    
    it "should work" do
      @klass.send(:search_parameters).should == [:somefield]
    end
  end

end