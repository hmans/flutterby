require 'flutterby/exporter'

describe Flutterby::Exporter do
  def export_path
    File::expand_path("../../tmp/flutterby_export/", __FILE__)
  end

  def cleanup!
    FileUtils.rm_rf(export_path)
  end

  def build!
    root = read "/"
    Flutterby::Exporter.new(root)
      .export!(into: export_path)
  end

  before(:all) do
    cleanup!
    build!
  end

  after(:all) do
    cleanup!
  end

  specify "it should build a site" do
  end
end
