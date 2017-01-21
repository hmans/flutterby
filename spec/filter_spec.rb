describe "Filters" do
  context "with an explicit HTML extension" do
    subject { Flutterby::Node.new("test.html.md") }

    it "is exported with an HTML extension" do
      expect(subject.full_name).to eq("test.html")
    end
  end

  context "with an image extension" do
    subject { Flutterby::Node.new("test.gif") }
    let(:view) { Flutterby::View.for(subject) }

    it "is exported with its original extension" do
      Flutterby::Filters.apply!(view)
      expect(subject.full_name).to eq("test.gif")
      # NOTE: this spec doesn't make a terrible amount of sense anymore.
    end
  end
end
