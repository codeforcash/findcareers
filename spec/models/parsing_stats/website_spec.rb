require "rails_helper"
require "shared_context_for_parsing_stats"

RSpec.describe ParsingStats::Website, type: :model do
  subject { described_class.new(:domain => "example.com") }

  it { is_expected.to validate_presence_of(:domain) }
  it { is_expected.to validate_uniqueness_of(:domain).case_insensitive }

  describe ".calculate_statistics" do
    include_context "parsing stats"

    it "returns per-provider parse statistics" do
      stats = described_class.calculate_statistics

      expect(stats.size).to eq 3
      expect(stats[0].attributes.except("id")).to eq({"provider_name" => nil,
                                                      "provider_id" => nil,
                                                      "total" => 1,
                                                      "success" => 0.0,
                                                      "failure" => 1.0})

      expect(stats[1].attributes.except("id")).to eq({"provider_name" => "a",
                                                      "provider_id" => 1,
                                                      "total" => 4,
                                                      "success" => 0.75,
                                                      "failure" => 0.25})

      expect(stats[2].attributes.except("id")).to eq({"provider_name" => "b",
                                                      "provider_id" => 2,
                                                      "total" => 2,
                                                      "success" => 0.5,
                                                      "failure" => 0.5})
    end
  end
end
