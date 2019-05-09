require "rails_helper"
require "shared_context_for_parsing_stats"

RSpec.describe ParsingStats::Provider, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  describe "#calculate_statistics" do
    include_context "parsing stats"

    it "returns per domain parsing statistics" do
      ParsingStats::ParseAttempt.success("sshaw.com", "http://sshaw.com", :website, "a")

      stats = described_class.find_by!(:name => "a").calculate_statistics

      expect(stats.size).to eq 2
      expect(stats[0].attributes.except("id")).to eq({"domain" => "foo.com",
                                                      "provider" => "a",
                                                      "total" => 4,
                                                      "success" => 0.75,
                                                      "failure" => 0.25})

      expect(stats[1].attributes.except("id")).to eq({"domain" => "sshaw.com",
                                                      "provider" => "a",
                                                      "total" => 1,
                                                      "success" => 1.0,
                                                      "failure" => 0.0})



    end
  end
end
