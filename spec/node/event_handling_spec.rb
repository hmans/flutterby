describe Flutterby::EventHandling do
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
