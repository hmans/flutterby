require 'slodown'
require 'sass'
require 'tilt'
require 'slim'
require 'toml'
require 'mime-types'
require 'json'

require "flutterby/version"
require "flutterby/node"
require "flutterby/filters"
require "flutterby/view"


module Flutterby
  extend self

  attr_writer :logger

  def from(fs_path, name: nil, parent: nil)
    name ||= ::File.basename(fs_path)

    if ::File.exist?(fs_path)
      Node.new(name, fs_path: fs_path, parent: parent)
    else
      raise "Path #{fs_path} could not be found."
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
