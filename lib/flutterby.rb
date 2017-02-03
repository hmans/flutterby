require 'active_support/all'
require 'toml'
require 'mime-types'
require 'json'
require 'colorize'

require "flutterby/dotaccess"
require "flutterby/version"
require "flutterby/tree_walker"
require "flutterby/event"
require "flutterby/node"
require "flutterby/filters"
require "flutterby/view"

module Flutterby
  extend self

  attr_writer :logger

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def config
    @config ||= Dotaccess[{}]
  end
end

# Add local lib directory of project using this gem to load path
$:.unshift File.join(Dir.getwd, "/lib")
