describe "markdown rendering" do
  subject { read "markdown.html.md" }

  describe "#body" do
    it "contains the file's source with all filters applied" do
      expect(subject.body).to eq("\n<h1 id=\"this-is-markdown\">This is Markdown</h1>\n\n<p>It’s great!</p>\n")
    end
  end
end
