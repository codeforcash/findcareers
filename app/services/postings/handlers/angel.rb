module Postings
  module Handlers
    class Angel < WebPageSourceHandler
      DOMAIN_REGEXP = /\bangel.com\b/

      def self.supports?(page)
        DOMAIN_REGEXP.match?(page)
      end

      def find(options = nil)
        startup_slug = parse_and_download(page).css('script#angellist_embed').first.attributes['data-startup'].value
        download_and_parse("https://angel.co/job_profiles/embed?startup=#{startup_slug}").css('a').count
      end
    end
  end
end
