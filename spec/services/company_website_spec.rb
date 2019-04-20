require "rails_helper"


describe CompanyWebsite, :type => :service do
  before { @website = "http://example.com" }

  describe ".find_careers_page" do
    it "calls CareersPageProcessor#get_careers_page" do
      klass = instance_double(CareersPageProcessor)
      expect(CareersPageProcessor).to receive(:new).and_return(klass)
      expect(klass).to receive(:get_careers_page).with(@website)

      described_class.find_careers_page(@website)
    end
  end

  describe ".extract_job_postings" do
    it "calls CareersPageParser#parse" do
      klass = instance_double(CareersPageParser)
      expect(CareersPageParser).to receive(:new).and_return(klass)
      expect(klass).to receive(:parse).with(@website)

      described_class.extract_job_postings(@website)
    end
  end

  describe ".import_jobs" do
    before { ENV["CODE_FOR_CASH_API_KEY"] = "testing" }

    it "imports jobs from the given website" do
      expected_postings = [
        Posting.new("Title 1", "Description 1", "#{@website}/1"),
        Posting.new("Title 2", "Description 2", "#{@website}/2", true, true)
      ]

      client = instance_double(CodeForCash::Client)
      allow(CodeForCash::Client).to receive(:new).with(ENV["CODE_FOR_CASH_API_KEY"]).and_return(client)

      expect(described_class).to receive(:find_careers_page).with(@website).and_return(@website)
      expect(described_class).to receive(:extract_job_postings).with(@website).and_return(expected_postings)

      expected_postings.each do |posting|
        expect(client).to receive(:create_posting).with(
                            :title => posting.title,
                            :description => posting.description,
                            :website => posting.url,
                            :remote => posting.remote?,
                            :part_time => posting.part_time?
                          )
      end

      postings = described_class.import_jobs(@website)
      expect(postings).to eq expected_postings
    end

    context "when the careers page cannot be found" do
      it "raises a CareersPageNotFound error" do
        allow(described_class).to receive(:find_careers_page).and_return(nil)
        expect {
          described_class.import_jobs(@website)
        }.to raise_error(described_class::CareersPageNotFound)
      end
    end
  end
end
