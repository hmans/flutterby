describe "Ruby nodes" do
  def ruby_code
    <<~EOF
    def body
      "<p>Hi, I'm a node written in Ruby!</p>"
    end
    EOF
  end

  specify "create a new node powered by custom Ruby code" do
    # node = read "ruby_node.rb"
    node = Flutterby::Node.new("ruby_node.rb", source: ruby_code)

    expect(node).to be_kind_of(Flutterby::Node)
    expect(node.ext).to eq("html")
    expect(node.body).to eq("<p>Hi, I'm a node written in Ruby!</p>")
  end
end
