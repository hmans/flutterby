describe "Sass Filter" do
  subject { read "css/styles.css.scss" }

  let :expected do
    "strong {\n  color: green; }\n\nbody {\n  color: red; }\n"
  end

  specify "converted into CSS, with working partials" do
    expect(subject.body).to eq(expected)
  end
end
