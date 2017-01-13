describe "html escaping" do
  context "with ERB" do
    subject do
      node "page.html.erb", source: source
    end

    let(:source) do
      <<~EOF
      <%= "Hi! <g>" %>
      EOF
    end

    its(:body) { is_expected.to include("Hi! &lt;g&gt;") }
  end

  context "with Slim" do
    subject do
      node "page.html.slim", source: source
    end

    let(:source) do
      <<~EOF
      = "Hi! <g>"
      EOF
    end

    its(:body) { is_expected.to include("Hi! &lt;g&gt;") }
  end
end
