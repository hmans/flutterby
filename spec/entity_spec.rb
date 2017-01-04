require_relative "spec_helper"

describe Flutterby::Entity do
  let(:parent) { double(path: "/foo") }

  it "assigns the name passed to the initializer" do
    @entity = Flutterby::Entity.new("bar", parent: parent)
    expect(@entity.name).to eq("bar")
  end
end
