describe "Ruby nodes" do
  def ruby_code
    <<~EOF
    def body
      "<p>Hi, I'm a node written in Ruby!</p>"
    end
    EOF
  end

  subject do
    Flutterby::Node.new("ruby_node.rb", source: ruby_code)
  end

  specify "create a new node powered by custom Ruby code" do
    expect(subject).to be_kind_of(Flutterby::Node)
    expect(subject.ext).to eq("html")
    expect(subject.body).to eq("<p>Hi, I'm a node written in Ruby!</p>")
  end
end
