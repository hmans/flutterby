describe "Node#data" do
  subject do
    node "data.json",
      source: %{{"foo": {"bar": "baz"}}}
  end

  let(:data) { subject.data }

  it "returns the node's data hash" do
    expect(data).to eq({"foo" => {"bar" => "baz"}})
  end

  it "supports the dot access syntax" do
    expect(data.foo.bar).to eq("baz")
  end

  it "supports indifferent access" do
    expect(data[:foo][:bar]).to eq("baz")
  end

  it "supports setting values" do
    expect { data.cow = "moo" }
      .to change { data[:cow] }
      .from(nil).to("moo")
  end
end
