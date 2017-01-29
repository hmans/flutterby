describe Flutterby::Deletion do
  subject { node "page.html" }

  describe '#delete!' do
    it "emits a :deleted event" do
      expect(subject).to receive(:emit).with(:deleted)
      subject.delete!
    end

    it "marks the node as deleted" do
      expect { subject.delete! }
        .to change { subject.deleted? }
        .from(false).to(true)
    end
  end
end
