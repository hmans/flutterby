# A _node.rb will be run against all nodes from the same directory -- use it
# to enhance the Ruby objects representing these nodes with extra methods
# or behavior.
#
# In this example, we're simply adding some convenience methods for easier
# access to specific pieces of data.

def date
  data["date"]
end

def title
  data["title"]
end
