require 'rails_helper'

RSpec.describe ParsingStats::ParseAttempt, type: :model do
  it { is_expected.to validate_presence_of(:website) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to define_enum_for(:url_type).with_values([:careers, :website]) }

  describe ".success" do
    context "with a provider" do
      before do
        described_class.success("example.com",
                                "http://example.com/careers",
                                :careers,
                                "Lever")
      end

      it "logs the attempt as success" do
        expect(described_class.last.detected).to eq true
      end

      it "sets the record's URL" do
        expect(described_class.last.url).to eq "http://example.com/careers"
      end

      it "sets the record's URL type" do
        expect(described_class.last.url_type).to eq "careers"
      end

      it "creates a website record" do
        expect(ParsingStats::Website).to exist(:domain => "example.com")
      end

      it "creates a provider record" do
        expect(ParsingStats::Provider).to exist(:name => "Lever")
      end

      it "only increments the website's success counter" do
        site = ParsingStats::Website.find_by!(:domain => "example.com")
        expect(site.success_count).to eq 1
        expect(site.failure_count).to eq 0
      end
    end

    context "without a provider" do
      before do
        described_class.success("example.com",
                                "http://example.com/careers",
                                :careers)
      end

      it "logs the attempt as success" do
        expect(described_class.last.detected).to eq true
      end

      it "sets the record's URL" do
        expect(described_class.last.url).to eq "http://example.com/careers"
      end

      it "sets the record's URL type" do
        expect(described_class.last.url_type).to eq "careers"
      end

      it "creates a website record" do
        expect(ParsingStats::Website).to exist(:domain => "example.com")
      end

      it "only increments the website's success counter" do
        site = ParsingStats::Website.find_by!(:domain => "example.com")
        expect(site.success_count).to eq 1
        expect(site.failure_count).to eq 0
      end
    end
  end

  describe ".failure" do
    context "without a provider" do
      before do
        described_class.failure("example.com",
                                "http://example.com/careers",
                                :careers,
                                "Some Error")
      end

      it "only increments the website's failed counter" do
        site = ParsingStats::Website.find_by!(:domain => "example.com")
        expect(site.failure_count).to eq 1
        expect(site.success_count).to eq 0
      end

      it "logs the attempt as a failure" do
        expect(described_class.last.detected).to eq false
      end

      it "sets the error message" do
        expect(described_class.last.error).to eq "Some Error"
      end

      it "sets the record's URL" do
        expect(described_class.last.url).to eq "http://example.com/careers"
      end

      it "sets the record's URL type" do
        expect(described_class.last.url_type).to eq "careers"
      end
    end

    context "with a provider" do
      before do
        described_class.failure("example.com",
                                "http://example.com/careers",
                                :careers,
                                "Some Error",
                                "Lever")
      end

      it "logs the attempt as a failure" do
        expect(described_class.last.detected).to eq false
      end

      it "sets the error message" do
        expect(described_class.last.error).to eq "Some Error"
      end

      it "sets the record's URL" do
        expect(described_class.last.url).to eq "http://example.com/careers"
      end

      it "sets the record's URL type" do
        expect(described_class.last.url_type).to eq "careers"
      end

      it "creates a provider record" do
        expect(ParsingStats::Provider).to exist(:name => "Lever")
      end
    end
  end
end
