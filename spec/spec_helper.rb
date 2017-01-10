$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "flutterby"
require "pry"

Flutterby.logger.level = Logger::FATAL

module Helpers
  def site_path
    ::File.expand_path("../site/", __FILE__)
  end

  def read(name)
    Flutterby.from ::File.join(site_path, name), name: name
  end
end

module ExportHelpers
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

  def generated_path(path)
    File.join(export_path, path)
  end

  def generated_file(path)
    File.read(generated_path(path))
  end
end

RSpec.configure do |c|
  c.include Helpers
end
