describe Dotaccess do
  let(:hash) do
    {
      foo: { "bar" => "baz" }
    }
  end

  subject { Dotaccess[hash] }

  it "returns proxie for values that are themselves hashes" do
    expect(subject.foo).to be_kind_of(Dotaccess::Proxy)
  end

  it "allows for deeply nested lookups of values" do
    expect(subject.foo.bar).to eq("baz")
  end

  it "returns nil for missing values" do
    expect(subject.foe).to be_nil
    expect(subject.foo.baz).to be_nil
  end

  it "allows for setting values" do
    expect { subject.cow = "moo" }
      .to change { subject.cow }
      .from(nil).to("moo")
  end

  it "allows to compare equality with other hashes" do
    expect(subject.foo).to eq({ "bar" => "baz" })
  end

  if RUBY_VERSION >= "2.3.0"
    it "allows for using the safe navigation operator" do
      expect(eval("subject&.foo&.bar")).to eq("baz")
      expect(eval("subject&.foe&.baz")).to be_nil
    end
  end
end
