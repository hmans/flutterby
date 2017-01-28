describe "frontmatter" do
  subject do
    node "page.html.md", source: source
  end

  let :source do
    <<-EOF
---
title: A file that tests Markdown.
---

This is a Markdown file with frontmatter.
EOF
  end

  specify "frontmatter is extracted" do
    expect(subject.data.title).to eq("A file that tests Markdown.")
  end


  context "with another triple-dash in the body" do
    let :source do
      <<-EOF
---
title: A file that tests Markdown.
---

foo: bar

---

This is a Markdown file with frontmatter.
EOF
    end

    specify "frontmatter is only extracted between the first two triple-dashes" do
      expect(subject.data.title).to eq("A file that tests Markdown.")
      expect(subject.data.foo).to eq(nil)
      expect(subject.render).to eq("\n<p>foo: bar</p>\n\n<hr>\n\n<p>This is a Markdown file with frontmatter.</p>\n")
    end
  end
end
