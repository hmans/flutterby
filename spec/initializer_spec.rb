describe "extending all nodes in a folder through _init.rb" do
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
    extend_siblings do
      on_setup do
        @test = "test"
      end

      def show_test
        @test
      end
    end
    EOF
  end

  specify "works :)" do
    root.stage!
    expect(page.render).to eq("I'm a page! This is a test!\n")
  end
end
