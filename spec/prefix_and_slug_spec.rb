describe "prefix and slug extraction" do
  context "when no prefix is available" do
    subject { node "foo.html.erb" }

    its(:prefix) { is_expected.to be_nil }
    its(:slug) { is_expected.to eq("foo") }
  end

  context "when a single prefix is available" do
    subject { node "123-foo.html.erb" }

    its(:prefix) { is_expected.to eq("123") }
    its(:slug) { is_expected.to eq("foo") }
  end

  context "when a multipart prefix is available" do
    subject { node "123-45-6789-foo.html.erb" }

    its(:prefix) { is_expected.to eq("123-45-6789") }
    its(:slug) { is_expected.to eq("foo") }
  end

  context "when a date prefix is available" do
    subject { node "2017-04-01-foo.html.erb" }

    its(:prefix) { is_expected.to eq("2017-04-01") }
    its(:slug) { is_expected.to eq("foo") }
    specify { expect(subject.data[:date]).to eq(Date.parse("2017-04-01")) }
  end
end
