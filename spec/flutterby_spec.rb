require "spec_helper"

describe Flutterby do
  it "has a version number" do
    expect(Flutterby::VERSION).not_to be nil
  end

  describe ".from" do
    context "when a directory is passed as an argument" do
      subject { read "" }

      it "returns an Node instance" do
        expect(subject).to be_a(Flutterby::Node)
      end

      it "name should match the directory name by default" do
        expect(subject.name).to eq("site")
      end
    end

    context "when a file is passed as an argument" do
      subject { read "markdown.html.md" }

      it "returns an Node instance" do
        expect(subject).to be_a(Flutterby::Node)
      end
    end

    context "when an invalid path is passed as an argument" do
      subject { read "whahahaahah_nil" }

      it "raises an exception" do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
