describe "Haml filter" do
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
  its(:body) { is_expected.to eq(expected_body)}
end
