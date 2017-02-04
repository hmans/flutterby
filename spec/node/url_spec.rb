describe Flutterby::Node do
  let!(:folder) { node "folder" }
  subject { folder.create "page.html.md" }

  describe '#path' do
    it "returns the node's path" do
      expect(subject.path).to eq("/folder/page.html")
    end

    context "on a deleted node" do
      before { subject.delete! }

      it "raises an exception" do
        expect { subject.path }.to raise_error "node has been deleted"
      end
    end

    context "on a node that lives within a deleted node" do
      before { folder.delete! }

      it "raises an exception" do
        expect { subject.path }.to raise_error "node has been deleted"
      end
    end

    context "when a URL prefix is given" do
      it "returns the prefixed path" do
        Flutterby.config.prefix = "http://www.foo.com/subdir/"
        expect(subject.path).to eq("/subdir/folder/page.html")
      end
    end

    context "when a path prefix is given" do
      it "returns the prefixed path" do
        Flutterby.config.prefix = "/subdir/"
        expect(subject.path).to eq("/subdir/folder/page.html")
      end
    end
  end

  describe '#internal_path' do
    context "when no prefix is configured" do
      it "returns the node's path" do
        expect(subject.internal_path).to eq("/folder/page.html")
      end

      it "is equal to #path" do
        expect(subject.internal_path).to eq(subject.path)
      end
    end

    context "when a prefix is configured" do
      before { Flutterby.config.prefix = "http://www.foo.com/subdir/" }

      it "is not affected" do
        expect(subject.internal_path).to eq("/folder/page.html")
      end
    end
  end

  describe '#url' do
    context "when no prefix is configured" do
      it "returns the path" do
        expect(subject.url).to eq("/folder/page.html")
      end
    end

    context "when a URL prefix is configured" do
      it "returns the full URL" do
        Flutterby.config.prefix = "http://www.foo.com/subdir/"
        expect(subject.url).to eq("http://www.foo.com/subdir/folder/page.html")
      end
    end

    context "when a path prefix is configured" do
      it "returns the path instead" do
        Flutterby.config.prefix = "/subdir/"
        expect(subject.url).to eq("/subdir/folder/page.html")
      end
    end
  end
end
