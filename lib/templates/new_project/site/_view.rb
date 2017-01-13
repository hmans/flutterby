# When you add a _view.rb file to a folder, all pages in this folder
# and all folders below it will have the methods defined in it available
# as view helper methods.


# Define a `config` view helper that provides quick access to the
# site configuration object's data.
#
def config
  find("/_config").data
end
