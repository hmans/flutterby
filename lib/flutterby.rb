require_relative "flutterby/entity"
require_relative "flutterby/file"
require_relative "flutterby/folder"
require_relative "flutterby/processor"

Flutterby::Processor
  .new("./in/")
  .export("./out/")
