require 'colorize'
require 'nokogiri'
require 'selenium-webdriver'
require 'final_redirect_url'
require 'hashie'

class CareersPageProcessor
  class Link < Hash
    include Hashie::Extensions::MethodAccess
  end

  def get_careers_page(url)
    # options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    # options.binary = ENV["GOOGLE_CHROME_BIN"]
    # @driver = Selenium::WebDriver.for(:chrome, options: options)

    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {
                                                              "args" => [ "--headless", "--no-sandbox" ]
                                                            })
    @driver = Selenium::WebDriver.for :remote, url: "https://#{ENV["BROWSERLESS_API_KEY"]}@chrome.browserless.io/webdriver", desired_capabilities: caps


    url = self.clean_url url
    logger.debug "Currently processing: #{url}"

    links = self.get_links(url)
    likely_links = self.select_careers_pages(links)

    logger.debug "Likely links: #{likely_links}"
    return if likely_links.empty?

    likely_links.each do |link|

      # Don't search deep links if we're already off site
      if link.href =~ /angel.co/
        deep_links = []
      else
        deep_links = self.get_links(link.href)
      end

      deep_links << link

      # We're just checking the href of the deep links, not executing any js

      if deep_links.any? {|link| link.href.include?('hire.withgoogle.com') }

        hwg = deep_links.select {|link| link.href.include?('hire.withgoogle.com') }.first.href

        if hwg.match(/hire.withgoogle.com\/public\/jobs\/([^\/]+)\/.+/)
          hirewithgoogle_coname = hwg.match(/hire.withgoogle.com\/public\/jobs\/([^\/]+)\/.+/)[1]
          return "https://hire.withgoogle.com/public/jobs/#{hirewithgoogle_coname}"
        else
          return hwg
        end

      elsif deep_links.any? {|link| link.href.match(/angel.co\/[^\/]+\/jobs.*/) }

        aco = deep_links.select {|link| link.href.match(/angel.co\/[^\/]+\/jobs.*/) }.first.href
        aco_coname = aco.match(/angel.co\/([^\/]+)\/jobs.*/)[1]
        return "https://angel.co/#{aco_coname}/jobs"

      elsif deep_links.any?{|link| link.href.include?('lever.co')}

        lco = FinalRedirectUrl.final_redirect_url(deep_links.select {|link| link.href.include?('lever.co') }.first.href)

        if lco.match(/jobs.lever.co\/[^\/]+\/.+/)
          lco_coname = lco.match(/jobs.lever.co\/([^\/]+)\//)[1]
          return "https://jobs.lever.co/#{lco_coname}"
        else
          return lco
        end

      elsif deep_links.any? {|link| link.href.include?('boards.greenhouse.io') }

        ghio = deep_links.select {|link| link.href.include?('boards.greenhouse.io') }.first.href

        if ghio.match(/greenhouse.io\/([^\/]+)\/.+/)
          gh_coname = ghio.match(/greenhouse.io\/([^\/]+)\/.+/)[1]
          return "https://boards.greenhouse.io/#{gh_coname}"
        else
          return ghio
        end

      elsif deep_links.any? {|link| link.href.include?('workable.com') }

        wco = FinalRedirectUrl.final_redirect_url(deep_links.select {|link| link.href.include?('workable.com') }.first.href)
        if wco.match(/\/\/[^\.]+\.workable\.com/)
          wconame = wco.match(/\/\/([^\.]+)\.workable\.com/)[1]
          return "https://#{wconame}.workable.com"
        else
          return wco
        end

      elsif link.text =~ /(view|see).+(career|job|position)/i

        return link.href

      elsif link.href =~ /(all\-jobs|positions)/

        return link.href
      end

      begin
        jobData = @driver.execute_script('return jobData')
        lever_name = jobData.first['applyLink'].match(/jobs.lever.co\/([^\/]+)/)[1]
        return "https://jobs.lever.co/#{lever_name}"
      rescue Exception => e
      end

    end

    return likely_links.first.href
  ensure
    @driver.quit if @driver
  end

  def clean_url(url_string)
    parsed = URI.parse(url_string.to_s)
    parsed.fragment = parsed.query = nil # get rid of the query string parameters
    parsed
  end

  # Modify this to return href and text

  def get_links(url)
    @driver.get(url)
    data = @driver.execute_script("return document.getElementsByTagName('html')[0].innerHTML")

    Nokogiri::HTML(data).css("a").map do |link|
      if (href = link.attr("href"))
        res = Link.new

        begin
          res.href = self.build_careers_page_url(url, href.strip).to_s
        rescue
          res.href = nil
        end
        res.text = link.text
        res
      end
    end.compact.reject do |link|
      link.href.nil?
    end.uniq
  end

  def select_careers_pages(links)
    links.select do |link|
      ['job', 'career', 'opening', 'position'].any?{ |x| link.href.include?(x) }
    end
  end

  def build_careers_page_url(url, link)
    url = clean_url(url)
    if link =~ /^(\/|#)/
      url + link
    elsif link =~ /^\./
      url + link[1..-1]
    else
      url + link
    end
  end

  private

  def logger
    Rails.logger
  end
end
