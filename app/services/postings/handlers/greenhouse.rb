require "final_redirect_url"
require "uri"
require "selenium-webdriver"

module Postings
  module Handlers
    class Greenhouse < WebPageSourceHandler
      DOMAIN_REGEXP = /\bgreenhouse.io\b/

      def self.supports?(page)
        DOMAIN_REGEXP.match?(page)
      end

      def find(options = nil)
        page_source = download(page)
        gh_token = extract_token(page_source)
        count = if gh_token
                  parse_json(download("https://boards-api.greenhouse.io/v1/boards/#{gh_token}/jobs"))['jobs'].count
                else
                  extract_js(url)
                end

        count == 0 ? [] : count.times.map { |i| Posting.new("Greenhouse Stub #{i}") }
      end

      private

      def parse_json(doc)
        JSON.parse(doc)
      rescue JSON::ParseError => e
        raise Error, "failed to parse JSON: #{e}"
      end

      def extract_token(page_source)
        nok = parse(page_source)

        greenhouse_links = nok.css('a').map{|x|x.attr('href')}.select{|x|x.include?('greenhouse.io')}
        greenhouse_iframes = nok.css('iframe').map{|x|x.attributes['src'].value}.select{|x|x.include?('grnh.se')}

        if greenhouse_links.count > 0
          token = greenhouse_links.first.match(/greenhouse.io\/([^\/]+)\//)[1]
        elsif greenhouse_iframes.count > 0
          # FIXME: Catch errors
          parsed = URI.parse(FinalRedirectUrl.final_redirect_url(greenhouse_iframes.first))
          parsed.fragment = parsed.query = nil # get rid of the query string parameters
          token = parsed.to_s.split('boards.greenhouse.io/').last
        else
          begin
            token = nok.css('meta[property="og:url"]').attr('content').value.split('boards.greenhouse.io/').last
            if token.match(/https?:/)
              token = get_token_from_script_tag(nok)
            end
          rescue
            token = get_token_from_script_tag(nok)
          end
        end

        token
      end

      def get_token_from_script_tag(nok)
        greenhouse_js_urls = nok.css('script').map { |x|
          x.attr('src')
        }.reject(&:nil?).select{ |x|
          x.include?('boards.greenhouse.io/embed/job_board/js')
        }
        if greenhouse_js_urls.count > 0
          greenhouse_js_urls.first.split('job_board/js?for=').last
        else
          nil
        end
      end

      def extract_js(url)
        options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
        driver = Selenium::WebDriver.for(:chrome, options: options)
        driver.get(url)
        ghjs = driver.execute_script('return ghjb_jobs')
        ghjs.count
      rescue => e
        raise Error, "failed to extract jobs using headless browser: #{e}"
      end
    end
  end
end
