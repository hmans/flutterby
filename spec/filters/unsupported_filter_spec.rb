describe "Unsupported filters" do
  subject { node "index.html.poop", source: source }

  let(:source) { "poop!" }

  its(:full_name) { is_expected.to eq("index.html.poop") }
  its(:render) { is_expected.to eq(source) }

  specify "does not log a warning, because filter is never executed" do
    expect(Flutterby.logger)
      .to_not receive(:warn)

    subject.render
  end
end
