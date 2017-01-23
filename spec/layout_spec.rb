describe "layouts" do
  let!(:root) { node "/" }

  let!(:outer_layout) do
    node "_layout.erb", parent: root, source: <<-EOF
<h1><%= "Outer Layout <g>" %></h1>
<%= yield %>
EOF
  end

  let!(:folder) do
    node "test", parent: root
  end

  let!(:page) do
    node "page.html", parent: folder, source: <<-EOF
<p>I'm the actual page!</p>
EOF
  end

  let!(:inner_layout) do
    node "_layout.erb", parent: folder, source: <<-EOF
<h2>Inner Layout</h2>
<%= yield %>
EOF
  end

  let(:expected_output) do
    %{<h1>Outer Layout &lt;g&gt;</h1>\n<h2>Inner Layout</h2>\n<p>I'm the actual page!</p>\n\n\n}
  end

  specify do
    expect(page.render(layout: true)).to eq(expected_output)
  end
end
