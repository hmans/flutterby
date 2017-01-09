describe "Ruby nodes" do
  specify "create a new node powered by custom Ruby code" do
    node = read "ruby_node.rb"

    expect(node).to be_kind_of(Flutterby::Node)
    expect(node.ext).to eq("html")
    expect(node.body).to eq("<p>Hi, I'm a node written in Ruby!</p>")
  end
end
