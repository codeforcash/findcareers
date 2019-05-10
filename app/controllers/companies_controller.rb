require "uri"

class CompaniesController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from StandardError do |e|
    error 500, e.message
  end

  def scrape_website
    if !valid_url?(params[:url])
      error(400, "http or https URL required")
      return
    end

    ScrapeCompanyWebsiteJob.perform_later(params[:url])
    head 202
  end

  private

  def error(status = 500, message = Rack::Utils::HTTP_STATUS_CODES[status])
    logger.error(message)
    render :status => status, :json => { :message => message }
  end

  def valid_url?(url)
    return false unless url
    URI(url).is_a?(URI::HTTP)
  rescue ArgumentError
    false
  end
end
