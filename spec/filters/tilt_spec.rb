# We're doing most template rendering through Tilt, so we can
# leverage this to dynamically fall back to it for template formats
# we don't support out of the box.

describe "Tilt template fallback" do
  let :source do
    <<-EOF
# RDoc test. +Yeah+!
EOF
  end

  let :expected_body do
    %{\n<p># RDoc test. <code>Yeah</code>!</p>\n}
  end

  subject do
    node "index.html.rdoc", source: source
  end

  its(:full_name) { is_expected.to eq("index.html") }
  its(:render) { is_expected.to eq(expected_body) }
end
