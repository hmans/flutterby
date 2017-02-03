describe Flutterby::Node do
  let(:folder) { node "folder" }
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

    context "on a node that lives within a delted node" do
      before { folder.delete! }

      it "raises an exception" do
        expect { subject.path }.to raise_error "node has been deleted"
      end
    end
  end

  describe '#url' do
    it "returns the path" do
      expect(subject.url).to eq("/folder/page.html")
    end
  end
end
