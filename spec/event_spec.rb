describe Flutterby::Event do
  def event(*args)
    Flutterby::Event.new(*args)
  end

  it "is equal to a symbol representing its name" do
    expect(event(:foo, source: nil)).to eq(:foo)
  end
end
