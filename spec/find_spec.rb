describe "#find" do
  # This is the node structure we'll be using for testing:
  #
  # root
  #   +-- foo
  #   +-- bar
  #         +-- baz
  #

  let!(:root) { node "/" }
  let!(:foo)  { node "foo", parent: root }
  let!(:bar)  { node "bar", parent: root }
  let!(:baz)  { node "baz.html", parent: bar }

  # add a secret folder with some equally secret data
  let!(:secret) { node "_secret", parent: root }
  let!(:data)   { node "data", parent: secret }

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

  specify "find(.) returns the parent" do
    expect(baz.find(".")).to eq(bar)
    expect(baz.find("./")).to eq(bar)
  end

  specify "find(..) returns the parent's parent" do
    expect(baz.find("..")).to eq(root)
    expect(baz.find("../")).to eq(root)
  end

  specify "crazy mixed expressions" do
    expect(baz.find("../foo")).to eq(foo)
    expect(baz.find("../foo/../bar/baz")).to eq(baz)
  end

  specify "reduce duplicate slashes" do
    expect(baz.find("..//bar")).to eq(bar)
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

  describe "private vs. public nodes" do
    specify "by default, finds within private nodes" do
      expect(root.find("_secret/data")).to eq(data)
    end

    context "with public_only set to true" do
      specify "it does not find private nodes" do
        expect(root.find("_secret/data", public_only: true)).to eq(nil)
      end
    end
  end
end
