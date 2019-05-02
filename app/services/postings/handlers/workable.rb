module Postings
  module Handlers
    class Workable < WebPageSourceHandler
      DOMAIN_REGEXP = /\bworkable.com\b/

      def self.supports?(page)
        DOMAIN_REGEXP.match?(page)
      end

      def find(options = nil)
        parse_and_download(page).css("ul.jobs li.job").count
      end
    end
  end
end
