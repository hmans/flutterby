describe Flutterby::File do
  let(:site_path) { ::File.expand_path("../site/", __FILE__) }

  subject { Flutterby.from ::File.join(site_path, "markdown.html.md") }

  it "correctly extracts its name and extension" do
    expect(subject.name).to eq("markdown")
    expect(subject.ext).to eq("html")
  end

  it "correctly extracts its filters" do
    expect(subject.filters).to eq(["md"])
  end

  it "extracts data from frontmatter" do
    expect(subject.data["title"]).to eq("A file that tests Markdown.")
  end

  context "when the filename contains a date" do
    subject { Flutterby.from ::File.join(site_path, "posts/2017-01-04-hello-world.html.md") }

    it "extracts the date" do
      expect(subject.data["date"]).to eq(Date.parse("2017-01-04"))
    end

    it "removed the date from the filename" do
      expect(subject.name).to eq("hello-world")
    end
  end
end
