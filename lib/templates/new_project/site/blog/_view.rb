def blog_posts
  siblings
    .select { |p| p.data["date"] }
    .sort_by { |p| p.data["date"] }
    .reverse
end
