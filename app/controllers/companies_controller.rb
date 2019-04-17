require "uri"

class CompaniesController < ApplicationController
  def scrape_website
    if !valid_url?(params[:url])
      error(400, "http or https URL required")
      return
    end

    ScrapeCompanyWebsiteJob.perform_later(params[:url])
    head 202
  end

  private

  def valid_url?(url)
    return false unless url
    URI(url).is_a?(URI::HTTP)
  rescue ArgumentError
    false
  end
end
