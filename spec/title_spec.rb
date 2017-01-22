describe 'Node#title' do
  subject { node "introduction.html.md" }
  its(:title) { is_expected.to eq("Introduction") }

  context "when the node name has a prefix" do
    subject { node "123-introduction.html.md" }
    its(:title) { is_expected.to eq("Introduction") }
  end

  context "when the node slag has multiple parts" do
    subject { node "hello-world.html.md" }
    its(:title) { is_expected.to eq("Hello World") }
  end

  context "when the node sets its own title data attribute" do
    subject { node "introduction.html.md", source: source }

    let(:source) do
      <<~EOF
      ---
      title: "A Great Introduction"
      ---

      Hi!
      EOF
    end

    its(:title) { is_expected.to eq("A Great Introduction") }
  end
end
