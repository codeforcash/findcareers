require "rails_helper"

require "code_for_cash/client"
require "json"

describe CodeForCash::Client do
  before do
    @key = "apikey"
    @endpoint = "https://i.codefor.cash/api/metum"
    @posting = {
      :title => "Foo",
      :description => "Bar",
      :website => "http://example.com/123",
      :remote => true,
      :part_time => true
    }
  end

  it "requires an API key" do
    [nil, "", "   "].each do |key|
      expect { described_class.new(key) }.to raise_error(ArgumentError, "API key required")
    end
  end

  describe "#create_posting" do
    before { @endpoint += "/create" }

    it "makes a call to the create endpoint with the provided values" do
      request = {
        :title => @posting[:title],
        :description => @posting[:description],
        :website => @posting[:website],
        :employment_type => "remote",
        :time_commitment => "parttime",
        :key => @key
      }

      stub_request(:post, @endpoint).and_return(:body => {:status =>  "success", :code => 1, :message => "success"}.to_json)
      described_class.new(@key).create_posting(@posting)
      expect(a_request(:post, @endpoint).with(:body => request)).to have_been_made
    end

    context "when a connection cannot be made" do
      it "raises a ConnectionError" do
        stub_request(:post, @endpoint).to_raise("oops")

        expect {
          described_class.new(@key).create_posting(@posting)
        }.to raise_error(described_class::ConnectionError, /failed to connect to .+: oops/)
      end
    end

    context "when the server returns an error message" do
      it "raises a RequestError" do
        stub_request(:post, @endpoint).and_return(
          :status => 200,
          :body => {status: "error", code: 1, message: "oops"}.to_json
        )

        expect {
          described_class.new(@key).create_posting(@posting)
        }.to raise_error(described_class::RequestError, "request failed with response: oops (code 1)")
      end
    end

    context "when the server returns a non-HTTP 200" do
      it "raises a RequestError" do
        stub_request(:post, @endpoint).and_return(
          :status => 500,
          :body => "oops"
        )

        expect {
          described_class.new(@key).create_posting(@posting)
        }.to raise_error(described_class::RequestError, "request failed with response: oops (HTTP 500)")
      end
    end
  end
end
