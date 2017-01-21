describe "Ruby nodes" do
  def ruby_code
    <<~EOF
    # Add a method to the node
    def generate_body
      "<p>I'm the body!</p>"
    end

    # Set the node's body
    self.body = generate_body
    EOF
  end

  subject do
    node "ruby_node.html.rb", source: ruby_code
  end

  specify "create a new node powered by custom Ruby code" do
    expect(subject).to be_kind_of(Flutterby::Node)
    expect(subject.ext).to eq("html")
    expect(subject.body).to eq("<p>I'm the body!</p>")
    expect(subject).to respond_to(:generate_body)
  end
end
