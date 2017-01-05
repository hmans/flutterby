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
end
