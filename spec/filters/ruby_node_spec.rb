describe "Ruby nodes" do
  def ruby_code
    <<~EOF
    tag(:p) { "I'm the body!" }
    EOF
  end

  subject do
    node "ruby_node.html.rb", source: ruby_code
  end

  specify "create a new node powered by custom Ruby code" do
    expect(subject).to be_kind_of(Flutterby::Node)
    expect(subject.ext).to eq("html")
    expect(subject.render).to eq("<p>I&#39;m the body!</p>")
  end
end
