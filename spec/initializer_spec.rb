describe "extending all nodes in a folder through _node.rb" do
  let!(:root) do
    node "/"
  end

  let!(:page) do
    node "page.html.erb", parent: root, source: <<~EOF
    I'm a page! This is a <%= node.show_test %>!
    EOF
  end

  let!(:initializer) do
    node "_init.rb", parent: root, source: <<~EOF
    module TestExtension
      def show_test
        "test"
      end
    end

    extend_siblings TestExtension
    EOF
  end

  specify "works :)" do
    root.stage!
    expect(page.body).to eq("I'm a page! This is a test!\n")
  end
end
