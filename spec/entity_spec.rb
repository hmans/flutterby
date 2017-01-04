require_relative "spec_helper"

describe Flutterby::Entity do
  let(:parent) { double(path: "/foo") }

  subject { Flutterby::Entity.new("bar", parent: parent) }

  it "assigns the name passed to the initializer" do
    expect(subject.name).to eq("bar")
  end

  context "when multiple extensions are given" do
    subject { Flutterby::Entity.new("index.html.slim.erb", parent: parent) }

    it "only uses the first extension for the name" do
      expect(subject.name).to eq("index.html")
    end

    it "stores the remaining extensions for processing" do
      expect(subject.extensions).to eq(["slim", "erb"])
    end
  end
end
