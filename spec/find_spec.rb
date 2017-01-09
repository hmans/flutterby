describe "#find" do
  # This is the node structure we'll be using for testing:
  #
  # root
  #   +-- foo
  #   +-- bar
  #         +-- baz
  #

  let!(:root) do
    Flutterby::Node.new("/").tap do |e|
      e.add_child foo
      e.add_child bar
    end
  end

  let(:foo) { Flutterby::Node.new("foo") }
  let(:baz) { Flutterby::Node.new("baz.html") }

  let(:bar) do
    Flutterby::Node.new("bar").tap do |e|
      e.add_child baz
    end
  end

  specify "normal singular expressions" do
    expect(root.find("foo")).to eq(foo)
    expect(root.find("bar")).to eq(bar)
  end

  specify "expressions starting with slash" do
    # Just a slash will always return root
    expect(root.find("/")).to eq(root)
    expect(baz.find("/")).to eq(root)

    # Expressions starting with a slash will start at root
    expect(baz.find("/foo")).to eq(foo)
    expect(baz.find("/bar/baz")).to eq(baz)
  end

  specify "find(.) returns the same node" do
    expect(foo.find(".")).to eq(foo)
    expect(foo.find("./")).to eq(foo)
  end

  specify "find(..) returns the parent" do
    expect(baz.find("..")).to eq(bar)
    expect(baz.find("../")).to eq(bar)
  end

  specify "crazy mixed expressions" do
    expect(baz.find("../..")).to eq(root)
    expect(bar.find("../foo")).to eq(foo)
    expect(bar.find("../foo/../bar/baz")).to eq(baz)
  end

  specify "reduce duplicate slashes" do
    expect(baz.find("..//baz")).to eq(baz)
  end

  specify "not found" do
    expect(root.find("moo")).to eq(nil)
  end

  specify "faulty expressions" do
    expect(root.find(" haha lol zomg ")).to eq(nil)
  end

  specify "with or without extensions" do
    expect(bar.find("baz")).to eq(baz)
    expect(bar.find("baz.html")).to eq(baz)
    expect(bar.find("baz.txt")).to eq(nil)
  end
end
