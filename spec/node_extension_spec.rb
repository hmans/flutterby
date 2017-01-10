describe "extending all nodes in a folder through _node.rb" do
  let!(:root) do
    Flutterby::Node.new "/"
  end

  let!(:page) do
    Flutterby::Node.new "page.html.erb", parent: root, source: <<~EOF
    I'm a page! This is a <%= node.show_test %>!
    EOF
  end

  let!(:extension) do
    Flutterby::Node.new "_node.rb", parent: root, source: <<~EOF
    def show_test
      "test"
    end
    EOF
  end

  specify "works :)" do
    root.stage!
    expect(page.body).to eq("I'm a page! This is a test!\n")
  end
end
