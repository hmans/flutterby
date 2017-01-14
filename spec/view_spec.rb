describe Flutterby::View do
  subject { node "page.html.erb", source: source }

  describe '#raw' do
    let(:source) { %{<%= raw "<g>" %>} }
    its(:body) { is_expected.to eq("<g>") }
  end

  describe '#html_escape' do
    let(:source) { %{<%= raw(html_escape "<g>") %>} }
    its(:body) { is_expected.to eq('&lt;g&gt;') }
  end

  describe '#h' do
    let(:source) { %{<%= raw(h "<g>") %>} }
    its(:body) { is_expected.to eq('&lt;g&gt;') }
  end
end
