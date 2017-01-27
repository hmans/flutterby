describe Flutterby::Node do
  let!(:root)   { node "/" }
  let!(:folder) { root.create("a_folder") }
  let!(:file)   { folder.create("file.txt") }
  let!(:page)   { folder.create("file.html.md") }

  describe '#page?, #file? and #folder?' do
    context "HTML page nodes" do
      subject { page }
      it { is_expected.to be_page }
      it { is_expected.to be_file }
      it { is_expected.to_not be_folder }
    end

    context "file nodes" do
      subject { file }
      it { is_expected.to_not be_page }
      it { is_expected.to be_file }
      it { is_expected.to_not be_folder }
    end

    context "folder nodes" do
      subject { folder }
      it { is_expected.to_not be_page }
      it { is_expected.to_not be_file }
      it { is_expected.to be_folder }
    end
  end

  describe '#create' do
    subject { folder.create("test.html") }

    its(:parent) { is_expected.to eq(folder) }
    its(:name) { is_expected.to eq('test') }
    its(:ext) { is_expected.to eq('html') }

    context 'when another parent is specified' do
      subject { folder.create("test.html", parent: file) }
      its(:parent) { is_expected.to eq(folder) }
    end
  end

  describe '#siblings' do
    context "when there's a parent" do
      subject { page }
      its(:siblings) { is_expected.to eq([file]) }
    end

    context "when there's no parent" do
      subject { root }
      its(:siblings) { is_expected.to eq(nil) }
    end
  end

  describe '#descendants' do
    it "returns a flat array with all of the node's descendants" do
      expect(root.descendants).to eq [folder, file, page]
    end
  end

  describe '#tree_size' do
    it "returns the size of the complete tree, starting with this node" do
      expect(root.size).to eq(4)
    end
  end

  describe '#move_to' do
    let!(:another_folder) { root.create("another_folder") }

    context "when specifying another node" do
      it "will move the node to that node" do
        expect { file.move_to(another_folder) }
          .to change { file.parent }
          .from(folder).to(another_folder)
      end
    end

    context "when specifying a path expression" do
      it "will move the node to the node found by the expression" do
        expect { file.move_to("/another_folder") }
          .to change { file.parent }
          .from(folder).to(another_folder)
      end

      context "when the path expression is invalid" do
        it "will raise an error" do
          expect { file.move_to("/INVALID") }
            .to raise_error %{Could not find node for path expression '/INVALID'}
        end
      end
    end

    context "when specifying another node" do
      it "will move the node to that node" do
        expect { file.move_to(nil) }
          .to change { file.parent }
          .from(folder).to(nil)
      end
    end
  end
end
