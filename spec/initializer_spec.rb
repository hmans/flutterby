describe "extending all nodes in a folder through _init.rb" do
  let!(:root) do
    node "/"
  end

  let!(:page) do
    root.create "page.html.erb",
      source: %{I'm a page! This is a <%= page.root.test %>!}
  end

  let!(:initializer) do
    node "_init.rb", parent: root, source: <<-EOF
on :created do
  @test = "test"
end

def test
  @test
end
EOF
  end

  specify "works :)" do
    root.stage!
    expect(root.test).to eq("test")
    expect(page.render).to eq("I'm a page! This is a test!")
  end
end
