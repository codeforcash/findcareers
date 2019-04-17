require 'rails_helper'

RSpec.describe ScrapeCompanyWebsiteJob, type: :job do
  it "imports jobs from the given URL" do
    expect(CompanyWebsite).to receive(:import_jobs).with("http://example.com")
    described_class.perform_now("http://example.com")
  end

  context "when the careers page cannot be found" do
    it "does not propagate the exception" do
      expect(CompanyWebsite).to receive(:import_jobs).and_raise(CompanyWebsite::PageNotFound)
      expect { described_class.perform_now("http://example.com") }.not_to raise_error
    end
  end
end
