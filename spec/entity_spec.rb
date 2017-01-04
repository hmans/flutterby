require_relative "spec_helper"

describe Flutterby::Entity do
  subject { Flutterby::Entity.new("bar", prefix: "/site/") }

  it "assigns the name passed to the initializer" do
    expect(subject.name).to eq("bar")
  end

  context "when multiple extensions are given" do
    subject { Flutterby::Entity.new("index.html.slim.erb", prefix: "/site/") }

    it "extracts name and extension" do
      expect(subject.name).to eq("index")
      expect(subject.ext).to eq("html")
    end

    it "stores the remaining extensions for processing" do
      expect(subject.extensions).to eq(["slim", "erb"])
    end
  end
end
