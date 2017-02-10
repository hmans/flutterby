describe "names, extensions and filters" do
  subject { node name }

  context "with a name like index.html.md.erb" do
    let(:name) { "index.html.md.erb" }

    its(:name) { is_expected.to eq("index") }
    its(:ext) { is_expected.to eq("html") }
    its(:filters) { is_expected.to eq(["erb", "md"]) }
    its(:full_name) { is_expected.to eq("index.html") }
  end

  context "with a name like jquery.min.js" do
    let(:name) { "jquery.min.js" }

    its(:name) { is_expected.to eq("jquery.min") }
    its(:ext) { is_expected.to eq("js") }
    its(:filters) { is_expected.to eq([]) }
    its(:full_name) { is_expected.to eq("jquery.min.js") }
  end

  context "with a name like static.txt" do
    let(:name) { "static.txt" }

    its(:name) { is_expected.to eq("static") }
    its(:ext) { is_expected.to eq("txt") }
    its(:filters) { is_expected.to eq([]) }
    its(:full_name) { is_expected.to eq("static.txt") }
  end
end
