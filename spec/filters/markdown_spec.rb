describe "markdown rendering" do
  subject { node "markdown.html.md", source: source }

  let :source do
    <<-EOF
# This is Markdown

It's great! Here's some Ruby code:

~~~ ruby
puts "OMG"
~~~
EOF
  end

  let :expected_body do
    %{<h1 id=\"this-is-markdown\">This is Markdown</h1>\n\n<p>It’s great! Here’s some Ruby code:</p>\n\n<pre><code class=\"language-ruby\">puts \"OMG\"\n</code></pre>\n}
  end

  its(:render) { is_expected.to eq(expected_body) }
end
