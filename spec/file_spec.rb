describe Flutterby::File do
  subject { read "markdown.html.md" }

  it "correctly extracts its name and extension" do
    expect(subject.name).to eq("markdown")
    expect(subject.ext).to eq("html")
  end

  it "correctly extracts its filters" do
    expect(subject.filters).to eq(["md", "html"])
  end

  it "extracts data from frontmatter" do
    expect(subject.data["title"]).to eq("A file that tests Markdown.")
  end

  context "when the filename contains a date" do
    subject { read "posts/2017-01-04-hello-world.html.md" }

    it "extracts the date" do
      expect(subject.data["date"]).to eq(Time.parse("2017-01-04"))
    end
  end

  describe "#body" do
    it "contains the file's contents with all filters applied" do
      expect(subject.body).to eq("\n<h1 id=\"this-is-markdown\">This is Markdown</h1>\n\n<p>It’s great!</p>\n")
    end
  end

  describe "JSON files" do
    subject { read "json_data.json" }

    it "imports the JSON object into #data" do
      expect(subject.data["name"]).to eq("Hendrik Mans")
      expect(subject.data["info"]["favoriteFood"]).to eq("Schnitzel")
    end
  end

  describe "YAML files" do
    subject { read "yaml_data.yaml" }

    it "imports the YAML into #data" do
      expect(subject.data["name"]).to eq("Hendrik Mans")
      expect(subject.data["info"]["favoriteFood"]).to eq("Schnitzel")
    end
  end
end
