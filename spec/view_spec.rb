describe Flutterby::View do
  subject { node "page.html.erb", source: %{<%= raw "<g>" %>} }

  describe '#raw' do
    let(:source) { %{<%= raw "<g>" %>} }
    its(:body) { is_expected.to eq("<g>") }
  end

  describe '#html_escape' do
    pending  # NOTE: test View instance instead
  end
end
