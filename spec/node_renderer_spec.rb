describe Flutterby::NodeRenderer do
  let(:page) do
    node "page.html.md", source: "# Hello world!"
  end

  let(:view) do
    Flutterby::View.for(page)
  end

  describe '#render' do
    it "renders the specified node against the specified view" do
      expect(Flutterby::NodeRenderer.render(page, view))
        .to eq(%{<h1 id="hello-world">Hello world!</h1>\n})
    end
  end
end
