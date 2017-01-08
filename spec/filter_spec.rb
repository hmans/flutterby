describe "Filters" do
  context "with an explicit HTML extension" do
    subject { Flutterby::File.new("test.html.md") }

    it "is exported with an HTML extension" do
      expect(subject.full_name).to eq("test.html")
    end
  end

  context "with no explicit HTML extension, but a filter that produces HTML" do
    subject { Flutterby::File.new("test.md") }

    it "is exported with an HTML extension" do
      subject.filtered_contents
      expect(subject.full_name).to eq("test.html")
    end
  end

  context "with an image extension" do
    subject { Flutterby::File.new("test.gif") }

    it "is exported with its original extension" do
      subject.filtered_contents
      expect(subject.full_name).to eq("test.gif")
    end
  end
end
