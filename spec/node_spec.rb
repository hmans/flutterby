describe Flutterby::Node do
  let!(:folder_node) { Flutterby::Node.new("a_folder") }
  let!(:file_node)   { Flutterby::Node.new("file.txt", parent: folder_node) }
  let!(:page_node)   { Flutterby::Node.new("file.html.md", parent: folder_node) }

  describe '#page?, #file? and #folder?' do
    context "HTML page nodes" do
      subject { page_node }
      it { is_expected.to be_page }
      it { is_expected.to be_file }
      it { is_expected.to_not be_folder }
    end

    context "file nodes" do
      subject { file_node }
      it { is_expected.to_not be_page }
      it { is_expected.to be_file }
      it { is_expected.to_not be_folder }
    end

    context "folder nodes" do
      subject { folder_node }
      it { is_expected.to_not be_page }
      it { is_expected.to_not be_file }
      it { is_expected.to be_folder }
    end
  end

  describe '#create' do
    subject { folder_node.create("test.html") }

    its(:parent) { is_expected.to eq(folder_node) }
    its(:name) { is_expected.to eq('test') }
    its(:ext) { is_expected.to eq('html') }

    context 'when another parent is specified' do
      subject { folder_node.create("test.html", parent: file_node) }
      its(:parent) { is_expected.to eq(folder_node) }
    end
  end

  describe '#siblings' do
    context "when there's a parent" do
      subject { page_node }
      its(:siblings) { is_expected.to eq([file_node]) }
    end

    context "when there's no parent" do
      subject { folder_node }
      its(:siblings) { is_expected.to eq(nil) }
    end
  end
end
