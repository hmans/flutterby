describe Flutterby::EventHandling do
  describe '#on' do
    let!(:root) { node "/" }
    let!(:foo)  { root.create "foo" }
    let!(:bar)  { root.create "bar" }

    it "registers an event handler" do
      foo.on(:created) do |node|
        node.data.name = "Foo"
      end

      root.stage!

      expect(foo.data.name).to eq "Foo"
    end

    context "without a selector" do
      it "creates a handler that will be executed for any node" do
        root.on(:created) do |node|
          root.data.nodes ||= []
          root.data.nodes << node
        end

        root.stage!

        expect(root.data.nodes).to eq [root, foo, bar]
      end
    end

    context "with a string selector" do
      it "creates a handler that will be executed for the node matching the path" do
        root.on(:created, "/foo") do |node|
          root.data.nodes ||= []
          root.data.nodes << node
        end

        root.stage!

        expect(root.data.nodes).to eq [foo]
      end
    end

    context "with a regexp selector" do
      it "creates a handler that will be executed for the node matching the path by regular expression" do
        root.on(:created, /foo/) do |node|
          root.data.nodes ||= []
          root.data.nodes << node
        end

        root.stage!

        expect(root.data.nodes).to eq [foo]
      end
    end

    context "with a proc selector" do
      it "creates a handler that will be executed for the node where proc evaluates to true" do
        root.on(:created, ->(n) { n.name == "foo" }) do |node|
          root.data.nodes ||= []
          root.data.nodes << node
        end

        root.stage!

        expect(root.data.nodes).to eq [foo]
      end
    end
  end


  describe "integration with initializers" do
    let!(:root) { node "/" }

    let!(:initializer) do
      root.create "_init.rb", source: <<-EOF
on :created do
  emit :set_foo
end
EOF
    end

    let!(:page) do
      root.create "page.html.erb", source: <<-EOF
Hallo <%= parent.data.foo %>!
EOF
    end

    specify do
      root.on :set_foo do
        root.data.foo = "foo"
      end

      root.stage!

      expect(page.render).to eq("Hallo foo!\n")
    end
  end
end
