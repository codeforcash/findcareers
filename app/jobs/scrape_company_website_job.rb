require "code_for_cash/client"

class ScrapeCompanyWebsiteJob < ApplicationJob
  queue_as :default

  def perform(url)
    CompanyWebsite.import_jobs(url)
  rescue CompanyWebsite::CareersPageNotFound => e
    # Don't retry these errors
    logger.error("Cannot import jobs for website '#{url}': #{e}")
  end
end
