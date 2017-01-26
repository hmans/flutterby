describe "layouts" do
  let!(:root) { node "/" }

  let!(:outer_layout) do
    node "_layout.html.erb", parent: root, source: <<-EOF
<h1><%= "Outer Layout <g>" %></h1>
<%= yield %>
EOF
  end

  let!(:folder) do
    node "test", parent: root
  end

  let!(:page) do
    node "page.html", parent: folder, source: <<-EOF
---
title: Page Title
---
<p>I'm the actual page!</p>
EOF
  end

  let!(:stylesheet) do
    node "styles.css", parent: folder,
      source: %[body { color: red }]
  end

  let!(:inner_layout) do
    node "_layout.html.erb", parent: folder, source: <<-EOF
<h2><%= page.title %></h2>
<%= yield %>
EOF
  end

  let!(:alternative_layout) do
    node "_alternative_layout.html.erb", parent: folder, source: <<-EOF
<h2>Alternative Inner Layout</h2>
<%= yield %>
EOF
  end

  context "with the normal layout behavior" do
    it "walks up the tree, applying all _layout files" do
      expect(page.render(layout: true))
        .to eq(%{<h1>Outer Layout &lt;g&gt;</h1>\n<h2>Page Title</h2>\n<p>I'm the actual page!</p>\n\n\n})
    end
  end

  context "with all layout disabled" do
    before do
      page.data[:layout] = false
    end

    it "doesn't apply any layouts" do
      expect(page.render(layout: true))
        .to eq(%{<p>I'm the actual page!</p>\n})
    end
  end

  context "with an alternative layout specified in the node data" do
    before do
      page.data[:layout] = "./_alternative_layout"
    end

    it "applies the specified layout, then walks up the tree" do
      expect(page.render(layout: true))
        .to eq(%{<h1>Outer Layout &lt;g&gt;</h1>\n<h2>Alternative Inner Layout</h2>\n<p>I'm the actual page!</p>\n\n\n})
    end
  end

  context "with multiple layouts specified (you crazy person, you)" do
    before do
      page.data[:layout] = ["/_layout", "./_alternative_layout", false]
    end

    it "applies the specified layout, then walks up the tree" do
      expect(page.render(layout: true))
        .to eq(%{<h2>Alternative Inner Layout</h2>\n<h1>Outer Layout &lt;g&gt;</h1>\n<p>I'm the actual page!</p>\n\n\n})
    end
  end

  context "with an alternative layout specified in the node data, and a false value" do
    before do
      page.data[:layout] = ["./_alternative_layout", false]
    end

    it "applies the specified layout, then stops" do
      expect(page.render(layout: true))
        .to eq(%{<h2>Alternative Inner Layout</h2>\n<p>I'm the actual page!</p>\n\n})
    end
  end

  context "with an alternative layout explicitly specified" do
    it "applies the specified layout, then stops" do
      expect(page.render(layout: "./_alternative_layout"))
        .to eq(%{<h2>Alternative Inner Layout</h2>\n<p>I'm the actual page!</p>\n\n})
    end
  end

  context "when rendering something that is not a HTML page" do
    specify "layouts are not applied automatically" do
      expect(stylesheet.render(layout: true))
        .to eq("body { color: red }")
    end
  end

  context "with a missing layout specified" do
    before do
      page.data[:layout] = "./_missing_layout"
    end

    it "applies the specified layout, then walks up the tree" do
      expect { page.render(layout: true) }
        .to raise_error("No layout found for path expression './_missing_layout'")
    end
  end
end
