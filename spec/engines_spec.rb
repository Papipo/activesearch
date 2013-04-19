#encoding: utf-8

require File.join(File.dirname(__FILE__), 'spec_helper')

def cleanup(engine)
  case engine
  when "Algolia"
    YAML.load_file(File.dirname(__FILE__) + '/../config/algolia.yml').tap do |config|
      ActiveSearch::Algolia::Client.configure(config["api_key"], config["app_id"])
    end
    ActiveSearch::Algolia::Client.new.delete_index
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
      @findable       = Object.const_get("#{engine}Model").create(title: "Findable Findable", junk: "Junk field", scope_id: 1)
      @quite_findable = Object.const_get("#{engine}Model").create(title: "Some title", text: "Findable text", scope_id: 1)
      @another        = Object.const_get("Another#{engine}Model").create(title: "Another <strong>findable</strong> title with tags", scope_id: 1)
      @junk           = Object.const_get("#{engine}Model").create(title: "Junk", junk: "Not Findable junk", scope_id: 1)
      @special        = Object.const_get("#{engine}Model").create(title: "Not findable because it's special", special: true, scope_id: 1)
      @foreign        = Object.const_get("#{engine}Model").create(title: "Findable", scope_id: 2)
    end
    
    it "should find the expected documents" do
      results = ActiveSearch.search("findable", scope_id: 1).map { |doc| doc.to_hash.select { |k,v| %w[title junk virtual].include?(k.to_s) } }
      results.sort_by { |result| result["title"] }.should == [
          {
            "title"   => "Another <strong>findable</strong> title with tags",
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
      ActiveSearch.search("findable").count.should == 3
    end
  end
end