describe Flutterby::Node do
  let!(:folder_node) { Flutterby::Node.new("a_folder") }
  let!(:file_node)   { Flutterby::Node.new("file.txt", parent: folder_node) }
  let!(:page_node)   { Flutterby::Node.new("file.html.md", parent: folder_node) }

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
