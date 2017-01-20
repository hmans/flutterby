describe Flutterby::View do
  subject { node "page.html.erb", source: source }

  describe '#raw' do
    let(:source) { %{<%= raw "<g>" %>} }
    its(:body) { is_expected.to eq("<g>") }
  end

  describe '#html_escape' do
    let(:source) { %{<%= raw(html_escape "<g>") %>} }
    its(:body) { is_expected.to eq('&lt;g&gt;') }
  end

  describe '#h' do
    let(:source) { %{<%= raw(h "<g>") %>} }
    its(:body) { is_expected.to eq('&lt;g&gt;') }
  end
end

describe "tag helpers" do
  let(:root) { node "/" }
  let(:foo)  { node "foo", parent: root }
  let(:bar)  { node "bar", parent: root }
  let(:view) { Flutterby::View.for(foo) }

  describe '#tag' do
    it "generates HTML tags" do
      expect(view.tag(:div, class: "foo")).to eq(%{<div class="foo"></div>})
    end

    it "properly escapes quotes in attributes" do
      expect(view.tag(:div, class: "foo\"bar")).to eq(%{<div class="foo&quot;bar"></div>})
    end

    it "properly escapes quotes in tag names" do
      expect(view.tag("foo\"bar", class: "foo")).to eq(%{<foo&quot;bar class="foo"></foo&quot;bar>})
    end
  end

  describe '#link_to' do
    it "generates links to nodes" do
      expect(view.link_to("Bar", bar)).to eq(%{<a href="/bar">Bar</a>})
    end

    it "generates links to URL strings" do
      expect(view.link_to("Bar", "http://bar.com")).to eq(%{<a href="http://bar.com">Bar</a>})
    end

    it "can use custom HTML attributes" do
      expect(view.link_to("Bar", bar, class: "foo")).to eq(%{<a class="foo" href="/bar">Bar</a>})
    end
  end
end

describe '#debug helper' do
  let(:page)   { node "page.html.erb" }
  let(:view)   { Flutterby::View.for(page) }

  context "when passed any object that can be serialized to YAML" do
    let(:object) { {bar: "baz"} }

    let(:expected_output) do
      %{<pre class=\"debug\">---\n:bar: baz\n</pre>}
    end

    it "dumps the object's YAML representation into a <pre> tag" do
      expect(view.debug(object)).to eq(expected_output)
    end
  end
end
