require 'active_support/all'
require 'toml'
require 'mime-types'
require 'json'
require 'colorize'

require "flutterby/dotaccess"
require "flutterby/version"
require "flutterby/tree_walker"
require "flutterby/node"
require "flutterby/node_renderer"
require "flutterby/filters"
require "flutterby/view"


module Flutterby
  extend self

  attr_writer :logger

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
