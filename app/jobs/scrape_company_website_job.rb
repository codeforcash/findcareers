require "code_for_cash/client"

class ScrapeCompanyWebsiteJob < ApplicationJob
  queue_as :default

  def perform(website)
    Postings.import(website)
  rescue Postings::CareersPageNotFound, Postings::CareersPageNotSupported => e
    # Don't retry on these errors
    logger.error("Cannot import postings for #{website}: #{e}")
  end
end
