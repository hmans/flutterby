describe "rendering" do
  let!(:root) { node "/" }
  let!(:page) { node "page.html.erb", parent: root, source: page_source }
  let!(:partial) { node "_partial.html.erb", parent: root, source: partial_source }

  subject { page }

  let :page_source do
    <<-EOF
<p>Let's render a partial!</p>
<%= find("./_partial.html").render() %>
EOF
  end

  let :partial_source do
    %{<p>I'm the partial!</p>}
  end

  describe "without partials" do
    specify do
      expect(partial.render).to eq("<p>I'm the partial!</p>")
    end
  end

  describe "rendering partials" do
    its(:render) { is_expected.to include("I'm the partial!") }

    context "when passing variables to the partial" do
      let :page_source do
        %{<%= find("./_partial.html").render(locals: {name: "John Doe"}) %>}
      end

      let :partial_source do
        %{Hello <%= locals[:name] %>!}
      end

      its(:render) { is_expected.to include("Hello John Doe!") }
    end
  end
end

describe Flutterby::Rendering do
  describe '#can_render?' do
    it "returns true if the node can be rendered" do
      folder = node("folder", source: nil)
      expect(folder.can_render?).to eq(false)
    end
  end

  describe '#render' do
    context "on a node that can't be rendered" do
      it "should raise an exception" do
        folder = node("folder", source: nil)
        expect{folder.render}.to raise_error("Nodes without source can't be rendered")
      end
    end
  end
end
