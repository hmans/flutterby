describe "rendering partials" do
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

  its(:render) { is_expected.to include("I'm the partial!") }

  context "when passing variables to the partial" do
    let :page_source do
      %{<%= find("./_partial.html").render(name: "John Doe") %>}
    end

    let :partial_source do
      %{Hello <%= opts[:name] %>!}
    end

    its(:render) { is_expected.to include("Hello John Doe!") }
  end
end
