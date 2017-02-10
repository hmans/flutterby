describe "names, extensions and filters" do
  subject { node name }

  context "with a name like index.html.md.erb" do
    let(:name) { "index.html.md.erb" }

    its(:name) { is_expected.to eq("index") }
    its(:ext) { is_expected.to eq("html") }
    its(:filters) { is_expected.to eq(["erb", "md"]) }
    its(:full_name) { is_expected.to eq("index.html") }
  end
end
