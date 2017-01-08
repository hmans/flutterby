describe "Filters" do
  context "with an explicit HTML extension" do
    subject { Flutterby::Node.new("test.html.md") }

    it "is exported with an HTML extension" do
      expect(subject.full_name).to eq("test.html")
    end
  end

  context "with no explicit HTML extension, but a filter that produces HTML" do
    subject { Flutterby::Node.new("test.md") }

    it "is exported with an HTML extension" do
      Flutterby::Filters.apply!(subject)
      expect(subject.full_name).to eq("test.html")
    end
  end

  context "with an image extension" do
    subject { Flutterby::Node.new("test.gif") }

    it "is exported with its original extension" do
      Flutterby::Filters.apply!(subject)
      expect(subject.full_name).to eq("test.gif")
    end
  end
end
