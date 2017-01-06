$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "flutterby"

module Helpers
  def site_path
    ::File.expand_path("../site/", __FILE__)
  end

  def read(name)
    Flutterby.from ::File.join(site_path, name)
  end
end

RSpec.configure do |c|
  c.include Helpers
end
