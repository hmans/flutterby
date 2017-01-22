describe "Ruby nodes" do
  let :ruby_code do
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

  context "with instance variables" do
    let :ruby_code do
      <<~EOF
      @message = "Hooray, instance variables in views!"
      tag(:p) { @message }
      EOF
    end

    its(:render) { is_expected.to eq("<p>Hooray, instance variables in views!</p>") }

    it "does not set the instance variable on the node" do
      expect(subject.instance_variable_get("@message")).to be_nil
    end
  end
end
