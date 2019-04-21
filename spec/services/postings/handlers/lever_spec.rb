require "rails_helper"


describe Postings::Handlers::Lever do
  before { @website = "jobs.lever.co" }

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

      expected_results = [
        Postings::Posting.new(:title => data.text, :description => data.description, :url => data.hostedUrl)
      ] * 2
      expect(lever.find).to eq expected_results
    end
  end
end
