require "rails_helper"


describe Postings::Handlers::Lever do
  before { @website = "http://jobs.lever.co" }

  describe ".supports?" do
    it "accepts anythinging beginning with 'jobs.lever.co" do
      expect(described_class.supports?(@website)).to eq true
      expect(described_class.supports?(@website + "/foo")).to eq true
      expect(described_class.supports?("blah")).to eq false
    end
  end

  describe ".new" do
    it "raises an ArgumentError if the company cannot be extracted from the website" do
      expect { described_class.new(@website + "/") }.to raise_error(ArgumentError, /does not have the company's name/)
    end
  end

  describe "#find" do
    it "retrieves postings for the company's URL" do
      data = Struct.new(:text, :description, :hostedUrl).new("Title", "Desc", @website + "/1")
      lever = described_class.new(@website + "/foo")

      expect(LeverPostings).to receive(:postings).with("foo", :skip => 0, :limit => 10).and_return([data])
      expect(LeverPostings).to receive(:postings).with("foo", :skip => 10, :limit => 10).and_return([data])
      expect(LeverPostings).to receive(:postings).with("foo", :skip => 20, :limit => 10).and_return([])

      results = lever.find
      expect(results.size).to eq 2

      expect(results[0].title).to eq "Title"
      expect(results[0].description).to eq "Desc"
      expect(results[0].url).to eq "http://jobs.lever.co/1"

      expect(results[1].title).to eq "Title"
      expect(results[1].description).to eq "Desc"
      expect(results[1].url).to eq "http://jobs.lever.co/1"
    end
  end
end
