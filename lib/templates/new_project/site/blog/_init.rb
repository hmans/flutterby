# A _init.rb file contains Ruby code that will be executed when
# your application boots up. It runs within the scope of this folder's node
# and can be used to set up event handlers, modify other nodes, and more.
#
# In this simple example, we're simply adding some convenience methods to
# all available blog posts for easier access to specific pieces of data.

on(:created, ->(n) { n.page? }) do |node|
  node.extend PostExtension
end

module PostExtension
  def date
    data.date
  end
end
