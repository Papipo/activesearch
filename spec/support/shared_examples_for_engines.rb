shared_examples 'an engine' do

  before(:all) do
    @findable       = @model.create(title: "Findable Findable", junk: "Junk field", scope_id: 1)
    @quite_findable = @model.create(title: "Some title", text: "Findable text", scope_id: 1)
    @another        = @another_model.create(title: "Another <strong>findable</strong> title with tags", scope_id: 1)
    @junk           = @model.create(title: "Junk", junk: "Not Findable junk", scope_id: 1)
    @special        = @model.create(title: "Not findable because it's special", special: true, scope_id: 1)
    @foreign        = @model.create(title: "Findable", scope_id: 2)
    @tagged         = @model.create(title: "Tagged document", tags: ['findable'], scope_id: 1)
    @localized      = @model.create(title: "Localized", color: "Red")
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
    @model.create(title: <<-LIPSUM, junk: "Junk field", scope_id: 1)
      Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy findable text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
    LIPSUM
    entry = ActiveSearch.search("dummy findable").first
    entry["highlighted"]["title"].should == "Lorem Ipsum is simply <em>dummy</em> text of the printing and typesetting industry. Lo..."
  end

  it "should paginate docs" do
    page = ActiveSearch.search("findable", {}, { page: 0, per_page: 2 })
    first_page_titles = page.map { |e| e['title'] }
    page.count.should == 2

    page = ActiveSearch.search("findable", {}, { page: 1, per_page: 2 })
    second_page_titles = page.map { |e| e['title'] }
    page.count.should == 2

    first_page_titles.should_not == second_page_titles
  end

end