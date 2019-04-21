require "rails_helper"

class TestHandler
  def initialize(id)
  end

  def find
    [ Postings::Posting.new("Title", "Description", "http://example.com/1") ]
  end

  def self.supports?(id)
    id == "example.com"
  end
end

describe Postings do
  describe ".find" do
    before { described_class::Handlers.const_set("TestHandler", TestHandler) }
    after  { described_class::Handlers.send(:remove_const, "TestHandler") }

    it "delegates to the appropriate handler" do
      expect(described_class::Handlers::TestHandler).to receive(:new).with("example.com").and_call_original
      described_class.find("example.com")
    end

    it "returns the postings found by the handler" do
      expect(described_class.find("example.com")).to eq [ described_class::Posting.new("Title", "Description", "http://example.com/1") ]
    end

    context "given an id for an unknown handler" do
      it "raises an ArgumentError" do
        expect { described_class.find("__FOO__") }.to raise_error(ArgumentError, "do not know how to find postings for id '__FOO__'")
      end
    end
  end
end
