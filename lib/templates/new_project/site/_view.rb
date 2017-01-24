# Use _view.rb files like this one to add helper methos to your views. Any
# helpers defined here will be available to all pages within the same
# folder, AND all of its sub-folders.

extend_view do
  # Define a `config` view helper that provides quick access to the
  # site configuration object's data.
  #
  def config
    find("/_config").data
  end
end
