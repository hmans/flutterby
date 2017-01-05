require "flutterby/version"
require "flutterby/entity"
require "flutterby/file"
require "flutterby/folder"
require "flutterby/view"
require "flutterby/server"

module Flutterby
  def Flutterby.from(fs_path, name: nil, parent: nil)
    name ||= ::File.basename(fs_path)

    if ::File.directory?(fs_path)
      Folder.new(name, fs_path: fs_path, parent: parent)
    elsif ::File.file?(fs_path)
      File.new(name, fs_path: fs_path, parent: parent)
    else
      raise "Path #{fs_path} could not be found."
    end
  end
end
