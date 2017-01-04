module Flutterby
  class File < Entity
    def read
      @contents = ::File.read(@path)
    end

    def write(path)
      ::File.write(path, @contents)
    end
  end
end
