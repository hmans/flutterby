describe "XMLBuilder filter" do
  let :source do
    <<~EOF
    xml.instruct! :xml, version: "1.0"
    xml.test do
      # We can access the current node because we're in a view
      xml.name node.name

      # Normale XML attributes
      xml.bar "baz"
    end
    EOF
  end

  let :output do
    %{<?xml version=\"1.0\" encoding=\"UTF-8\"?><test><name>feed</name><bar>baz</bar></test>}
  end

  subject do
    node "feed.xml.builder", source: source
  end

  specify "renders to XML" do
    expect(subject.body).to eq(output)
  end
end
