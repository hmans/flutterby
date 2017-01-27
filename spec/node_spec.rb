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
    pending
  end

  describe '#move_to' do
    pending
  end
end
