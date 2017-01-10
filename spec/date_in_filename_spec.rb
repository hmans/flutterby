describe "dates in file names" do
  subject { read "posts/2017-01-04-hello-world.html.md" }

  specify "the date is extracted from the file name" do
    expect(subject.data["date"]).to eq(Time.parse("2017-01-04"))
  end
end
