describe "names, extensions and filters" do
  subject { Flutterby::Node.new(name) }
  let(:name) { "index.html.md.erb" }

  it "uses the first part as its name" do
    expect(subject.name).to eq("index")
  end

  it "uses the second part as its target extension" do
    expect(subject.ext).to eq("html")
  end

  it "uses the remaining extensions as filters" do
    expect(subject.filters).to eq(["erb", "md"])
  end
end
