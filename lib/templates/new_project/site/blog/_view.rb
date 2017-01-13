# Returns all blog posts contained in this directory. We assume
# that a blog post is any page object that has a date set.
#
def blog_posts
  siblings
    .select { |p| blog_post?(p) }
    .sort_by(&:date)
    .reverse
end

# Checks if a specific node is a blog post.
#
def blog_post?(node)
  node.page? && !node.date.nil?
end
