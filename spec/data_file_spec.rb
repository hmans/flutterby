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

describe "data files with extra extensions" do
  specify "have their extra processing performed" do
    node = read "json_with_erb.json.erb"
    expect(node.data["foo"]).to eq("bar")
  end
end
