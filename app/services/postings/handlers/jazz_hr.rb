module Postings
  module Handlers
    class JazzHR < WebPageSourceHandler
      DOMAIN_REGEXP = /\b(?:app.jazz.co|applytojob.com)\b/

      def self.supports?(page)
        DOMAIN_REGEXP.match?(page)
      end

      def find(options = nil)
        page_source = download(page)

        begin
          # They embed a Jazz HR widget
          jazz_widget_url = parse(page_source).css('script').map{|x|x.attr('src')}.reject(&:nil?).select{|x|x.include?('app.jazz.co/widgets')}.first
          download_and_parse(jazz_widget_url).css('.resumator-job-title').count
        rescue
          # They use Jazz HR but embed links directly on page
          parse(page_source).css('a').map{|x|x.attr('href')}.select{|x|x.match(/applytojob.com\/apply\/.+/)}.count
        end
      end
    end
  end
end
