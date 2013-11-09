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
    Mongoid.purge!
  end
end

Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].map { |f| File.basename(f, '.rb') }.each do |filename|
  engine = filename.split('_').collect { |w| w.capitalize }.join
  next unless engine == "Algolia"
  describe "ActiveSearch::#{engine}" do
    before(:all) do
      I18n.locale = :en
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
      @tagged         = Object.const_get("#{engine}Model").create(title: "Tagged document", tags: ['findable'], scope_id: 1)
      @localized      = Object.const_get("#{engine}Model").create(title: "Localized", color: "Red")
      I18n.with_locale :es do
        @localized.color = "Rojo"
        @localized.save
      end
    end
    
    it "should find the expected documents" do
      results = ActiveSearch.search("findable", scope_id: 1).map { |doc| doc.select { |k,v| %w[title junk virtual].include?(k.to_s) } }
      results.sort_by { |result| result["title"] }.should == [
          {
            "title"   => "Another findable title with tags",
            "virtual" =>  "virtual"
          },
          {
            "title"  => "Findable Findable",
            "junk"   => "Junk field"
          },
          {
            "title"  => "Some title"
          },
          {
            "title"  => "Tagged document"
          }
        ]
      ActiveSearch.search("some text").first["title"].should == "Some title"
      ActiveSearch.search("junk").first["title"].should == "Junk"
    end
    
    it "should handle localized fields" do
      ActiveSearch.search("Localized").first["color"].should == "Red"
      I18n.with_locale :es do
        ActiveSearch.search("Localized").first["color"].should == "Rojo"
      end
    end
    
    it "should find docs even with upcase searches" do
      ActiveSearch.search("FINDABLE").count.should == 5
    end

    it "should remove destroyed documents from index" do
      @findable.destroy
      ActiveSearch.search("findable").count.should == 4
    end
    
    it "should excerpt and highlight" do
      Object.const_get("#{engine}Model").create(title: <<-LIPSUM, junk: "Junk field", scope_id: 1)
        Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy findable text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
      LIPSUM
      ActiveSearch.search("dummy findable").first["highlighted"]["title"].should == "Lorem Ipsum is simply <em>dummy</em> text of the printing and typesetting industry. Lo..."
    end
  end
end