require 'commander'

Commander.configure do
  program :name, 'Flutterby'
  program :version, Flutterby::VERSION
  program :description, 'There are many static site generators. This one is mine.'
end
