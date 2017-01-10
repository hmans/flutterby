require 'flutterby/exporter'

describe Flutterby::Exporter do
  include ExportHelpers

  before(:all) do
    cleanup!
    build!
  end

  after(:all) do
    cleanup!
  end

  specify "renders markdown to HTML" do
    expect(generated_file("markdown.html"))
      .to eq(%{\n<h1 id="this-is-markdown">This is Markdown</h1>\n\n<p>It’s great!</p>\n})
  end

  specify "renders Scss to CSS" do
    expect(generated_file("css/styles.css"))
      .to eq(%{body {\n  color: red; }\n})
  end

  specify "creates subdirectories" do
    expect(File.directory?(generated_path("/posts"))).to be_truthy
  end
end
