# We're doing most template rendering through Tilt, so we can
# leverage this to dynamically fall back to it for template formats
# we don't support out of the box.

require 'haml'

describe "Tilt template fallback" do
  let :source do
    <<~EOF
    %ul.foo
      %li.bar baz
    EOF
  end

  let :expected_body do
    %{<ul class='foo'>\n  <li class='bar'>baz</li>\n</ul>\n}
  end

  subject do
    node "index.html.haml", source: source
  end

  its(:full_name) { is_expected.to eq("index.html") }
  its(:body) { is_expected.to eq(expected_body) }
end
