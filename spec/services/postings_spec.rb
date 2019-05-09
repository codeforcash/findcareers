require "rails_helper"

class TestHandler < Postings::Handlers::Handler
  def initialize(id)
  end

  def find
    [ Postings::Posting.new("Title", "Description", "http://example.com/1") ]
  end

  def self.supports?(url)
    url == "http://example.com/careers"
  end
end

describe Postings do
  describe ".import" do
    before { ENV["CODE_FOR_CASH_API_KEY"] = "testing" }

    it "imports and returns postings found on the given website" do
      expected_postings = [
        Postings::Posting.new("Title 1", "Description 1", "#{@website}/1"),
        Postings::Posting.new("Title 2", "Description 2", "#{@website}/2", true, true)
      ]

      client = instance_double(CodeForCash::Client)
      allow(CodeForCash::Client).to receive(:new).with(ENV["CODE_FOR_CASH_API_KEY"]).and_return(client)

      expect(described_class).to receive(:find).with(@website).and_return(expected_postings)
      expected_postings.each do |posting|
        expect(client).to receive(:create_posting).with(
                            :title => posting.title,
                            :description => posting.description,
                            :website => posting.url,
                            :remote => posting.remote?,
                            :part_time => posting.part_time?
                          )
      end

      postings = described_class.import(@website)
      expect(postings).to eq expected_postings
    end
  end

  describe ".find" do
    before do
      @url = "https://example.com"
      described_class::Handlers.const_set("TestHandler", TestHandler)
    end

    after  { described_class::Handlers.send(:remove_const, "TestHandler") }

    it "requires an http or https URL" do
      ["ftp://example.com/foo", "example.com", "", " ", nil].each do |value|
        expect { described_class.find(value) }.to raise_error(ArgumentError, "http(s) URL required")
      end
    end

    it "returns postings found on the site's careers page" do
      processor = instance_double(CareersPageProcessor)
      allow(processor).to receive(:get_careers_page).with(@url).and_return("http://example.com/careers")
      allow(CareersPageProcessor).to receive(:new).and_return(processor)

      expect(described_class.find(@url)).to eq [ described_class::Posting.new("Title", "Description", "http://example.com/1") ]
    end

    context "when the given site's careers page cannot be found" do
      it "raises a CareersPageNotFound error" do
        processor = instance_double(CareersPageProcessor)
        allow(CareersPageProcessor).to receive(:new).and_return(processor)
        allow(processor).to receive(:get_careers_page).with(@url).and_return(nil)

        expect { described_class.find(@url) }.to raise_error(described_class::CareersPageNotFound, "cannot find careers page for #@url")
      end
    end

    context "when the careers page has no handler" do
      it "raises a CareersPageNotSupported error" do
        page = @url + "/foo"

        processor = instance_double(CareersPageProcessor)
        allow(CareersPageProcessor).to receive(:new).and_return(processor)
        allow(processor).to receive(:get_careers_page).with(@url).and_return(page)

        expect { described_class.find(@url) }.to raise_error(described_class::CareersPageNotSupported, "do not know how to find postings for #{page}")
      end
    end
  end
end
