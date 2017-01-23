# A _init.rb file contains Ruby code that will be executed when
# your application boots up. Use it to extend and modify other nodes!
#
# In this simple example, we're simply adding some convenience methods to
# all available blog posts for easier access to specific pieces of data.

extend_siblings do
  def date
    data.date
  end
end
