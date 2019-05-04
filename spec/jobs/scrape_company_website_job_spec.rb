require "rails_helper"

RSpec.describe ScrapeCompanyWebsiteJob, type: :job do
  it "imports jobs from the given URL" do
    expect(Postings).to receive(:import).with("http://example.com")
    described_class.perform_now("http://example.com")
  end

  context "when a careers page cannot be found" do
    it "does not propagate the exception" do
      expect(Postings).to receive(:import).and_raise(Postings::CareersPageNotFound)
      expect { described_class.perform_now("http://example.com") }.not_to raise_error
    end
  end

  context "when the careers page is not supported" do
    it "does not propagate the exception" do
      expect(Postings).to receive(:import).and_raise(Postings::CareersPageNotSupported)
      expect { described_class.perform_now("http://example.com") }.not_to raise_error
    end
  end
end
