require "code_for_cash/client"

class CompanyWebsite
  Error = Class.new(StandardError)
  CareersPageNotFound = Class.new(Error)

  class << self
    ##
    # Find the careers page for +website+ and attempt to find and import jobs using CodeForCash::Client
    # CodeForCash::Client's API must be set using the CODE_FOR_CASH_API_KEY environment variable.
    #
    # <strong>Note that on failure a partial import can occur.</strong>
    #
    # === Arguments
    #
    # [website (String)] - URL to attempt to import jobs from
    #
    # === Returns
    #
    # An +Array+ of +Posting+s that were imported.
    #
    # === Errors
    #
    # * ArgumentError - If the no CodeForCash API key has been set
    # * CareersPageNotFound - If the careers page cannot be located
    # * Error - If the import did not succeed
    #

    def import_jobs(website)
      # TODO: pass as an argument..?
      cfc = CodeForCash::Client.new(ENV["CODE_FOR_CASH_API_KEY"])

      url = find_careers_page(website)
      raise CareersPageNotFound, "cannot find careers page for #{website}" unless url

      imported = 0
      postings = extract_job_postings(url)
      postings.each do |posting|
        begin
          cfc.create_posting(
            :title => posting.title,
            :description => posting.description,
            :website => posting.url,
            :remote => posting.remote?,
            :part_time => posting.part_time?
          )
          imported += 1
        rescue => e
          raise Error, "import error, only #{imported}/#{postings.size} imported: #{e}"
        end
      end

      postings
    end

    ##
    # Find the careers page for +website+.
    #
    # === Returns
    #
    # A +String+: the careers page URL. Or +nil+ if it was not found.
    #

    def find_careers_page(website)
      raise ArgumentError, "website required" unless website.present?
      CareersPageProcessor.new.get_careers_page(website)
    end

    ##
    #
    # Extract job posting from the given careers page URL.
    #
    # === Returns
    #
    # An +Array+ of +Posting+s
    #
    # === Errors
    #
    #  TODO
    #

    def extract_job_postings(careers_page_url)
      raise ArgumentError, "careers page URL required" unless careers_page_url.present?
      Postings.find(careers_page_url)
    end
  end
end
