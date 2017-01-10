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

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
