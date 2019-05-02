module Postings
  module Handlers
    class HireWithGoogle < WebPageSourceHandler
      DOMAIN_REGEXP = /\bhire.withgoogle.io\b/

      def self.supports?(page)
        DOMAIN_REGEXP.match?(page)
      end

      def find(options = nil)
        nok = parse_and_download(page)
        script_tags = nok.css('script').map{ |x|
          x.attr('src')
        }.reject(&:nil?).select{ |x|
          x.include?('hire.withgoogle.com')
        }

        if script_tags.count >= 1
          begin
            hirewithgoogle_coname = script_tags.first.match(/https:\/\/hire.withgoogle.com\/s\/embed\/hire-jobs.js\?company=(.+)/)[1]
            hirewithgoogle_url = "https://hire.withgoogle.com/public/jobs/#{hirewithgoogle_coname}"
            content = download(hirewithgoogle_url)
          rescue
            content = page_source
          end

          parse(content).css('li a').count
        else
          hirewithgoogle_coname = nok.css('a').map{|x|x.attr('href')}.reject(&:nil?).select{|x|x.include?('hire.withgoogle.com')}.first.match(/hire.withgoogle.com\/public\/jobs\/([^\/]+)\/.+/)[1]
          nok.css('h5.career-job').count
        end
      end
    end
  end
end
