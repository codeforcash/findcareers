require "code_for_cash/client"

class CompanyWebsite
  Error = Class.new(StandardError)
  # Better: CareersPageNotFound
  PageNotFound = Class.new(Error)

  class << self
    def import_jobs(website)
      url_required(website)
      cfc = CodeForCash::Client.new(ENV["CODE_FOR_CASH_API_KEY"])

      url = find_careers_page(website)
      raise PageNotFound, "cannot find careers page for #{url}" unless url

      postings = extract_job_postings(url)
      postings.each do |posting|
        cfc.create_posting(
          :title => posting.text,
          :description => posting.description,
          :website => posting.url,
          :remote => posting.remote?,
          :part_time => posting.part_time?
        )
      end
    end

    def find_careers_page(url)
      url_required(url)
      CareersPageProcessor.new.get_careers_page(url)
    end

    def extract_job_postings(url)
      url_required(url)
      CareersPageParser.new.parse(url)
    end

    private

    def url_required(url)
      raise ArgumentError, "URL required" unless url.present?
    end
  end
end
