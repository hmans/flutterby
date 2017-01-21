describe "html escaping" do
  context "with ERB" do
    subject do
      node "page.html.erb", source: source
    end

    let(:source) do
      <<~EOF
      <p><%= "Hi! <g>" %></p>
      EOF
    end

    its(:render) { is_expected.to include("<p>Hi! &lt;g&gt;</p>") }
  end

  context "with Slim" do
    subject do
      node "page.html.slim", source: source
    end

    let(:source) do
      <<~EOF
      p = "Hi! <g>"
      EOF
    end

    its(:render) { is_expected.to include("<p>Hi! &lt;g&gt;</p>") }
  end
end
