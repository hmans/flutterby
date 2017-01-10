describe "frontmatter" do
  subject { read "markdown.html.md" }

  specify "frontmatter is extracted" do
    expect(subject.data["title"]).to eq("A file that tests Markdown.")
  end
end
