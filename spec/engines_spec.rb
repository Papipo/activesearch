#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

def cleanup(engine)
  case engine
  when "ElasticSearch"
    Tire::Configuration.client.delete "#{Tire::Configuration.url}/_all"
    load File.join(File.dirname(__FILE__), 'models', 'elastic_search.rb')
  when "Mongoid"
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end
end

Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].map { |f| File.basename(f, '.rb') }.each do |filename|
  engine = filename.split('_').collect { |w| w.capitalize }.join
  
  describe "ActiveSearch::#{engine}" do
    before(:all) do
      require File.join(File.dirname(__FILE__), 'models', filename)
    end
    
    before do
      cleanup(engine)
      @findable       = Object.const_get("#{engine}Model").create(title: "Findable Findable", junk: "Junk field")
      @quite_findable = Object.const_get("#{engine}Model").create(title: "Some title", text: "Findable text")
      @another        = Object.const_get("Another#{engine}Model").create(title: "Another findable title")
      @junk           = Object.const_get("#{engine}Model").create(title: "Junk", junk: "Not Findable junk")
      @special        = Object.const_get("#{engine}Model").create(title: "Not findable because it's special", special: true)
    end
    
    it "should find the expected documents" do
      results = ActiveSearch.search("findable").map { |doc| doc.to_hash.select { |k,v| %w[title junk virtual].include?(k.to_s) } }
      results.sort_by { |result| result["title"] }.should == [
          {
            "title"   => "Another findable title",
            "virtual" =>  "virtual"
          },
          {
            "title"  => "Findable Findable",
            "junk"   => "Junk field"
          },
          {
            "title"  => "Some title"
          },
        ]
      ActiveSearch.search("some text").first.to_hash["title"].should == "Some title"
      ActiveSearch.search("junk").first.to_hash["title"].should == "Junk"
    end

    it "should remove destroyed documents from index" do
      @findable.destroy
      ActiveSearch.search("findable").count.should == 2
    end
  end
end