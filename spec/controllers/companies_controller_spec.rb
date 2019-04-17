require "rails_helper"

RSpec.describe CompaniesController, type: :controller do
  describe "POST to #scrape_website" do
    before { @valid_url = "http://example.com" }

    it "requires an HTTP or HTTPS URL" do
      error = { :message => "http or https URL required" }.to_json

      post :scrape_website

      expect(response).to have_http_status(400)
      expect(response.body).to eq(error)

      post :scrape_website, :params => { :url => "ftp://foo.com" }

      expect(response).to have_http_status(400)
      expect(response.body).to eq(error)

      post :scrape_website, :params => { :url => "file:///etc/password" }

      expect(response).to have_http_status(400)
      expect(response.body).to eq(error)
    end

    context "when an error occurs enqueuing the job" do
      it "returns an HTTP 500" do
        allow(ScrapeCompanyWebsiteJob).to receive(:perform_later).and_raise("something bad happened")

        post :scrape_website, :params => { :url => @valid_url }

        expect(response).to have_http_status(500)
        expect(response.body).to eq({:message => "something bad happened"}.to_json)
      end
    end

    context "given a valid URL" do
      before { allow(ScrapeCompanyWebsiteJob).to receive(:perform_later) }

      it "enqueues a job to scrape the given URL" do
        expect(ScrapeCompanyWebsiteJob).to receive(:perform_later).with(@valid_url)
        post :scrape_website, :params => { :url => @valid_url }
      end

      it "returns an empty HTTP 202" do
        post :scrape_website, :params => { :url => @valid_url }

        expect(response).to have_http_status(202)
        expect(response.body).to be_empty
      end
    end
  end
end
