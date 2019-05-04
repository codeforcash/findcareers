#require "postings/handlers"
require "uri"
require "code_for_cash/client"

module Postings
  Error = Class.new(StandardError)
  ImportError = Class.new(Error)
  CareersPageNotFound = Class.new(Error)
  CareersPageNotSupported = Class.new(Error)

  #
  # A job posting.
  #
  # +part_time?+ and +remote?+ default to +false+.
  #

  Posting = Struct.new(:title, :description, :url, :part_time, :remote) do
    def part_time?
      @part_time = false if @part_time.nil?
      @part_time
    end

    def remote?
      @remote = false if @remote.nil?
      @remote
    end
  end

  class << self
    def import(url)
      imported = 0

      # TODO: pass as an argument..?
      cfc = CodeForCash::Client.new(ENV["CODE_FOR_CASH_API_KEY"])

      postings = find(url)
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
          raise ImportError, "import error, only #{imported}/#{postings.size} imported: #{e}"
        end
      end

      postings
    end

    ##
    #
    # Find the careers page for +url+ and attempt to extract +Posting+s from it.
    #
    # === Returns
    #
    # An Array of +Posting+s
    #
    # === Errors
    #
    # * ArgumentError - If no URL or an invalid URL was provided
    # * CareersPageNotFound - If the careers page cannot be located
    # * CareersPageNotSupported - If the careers page cannot be located
    #

    def find(url)
      raise ArgumentError, "http(s) URL required" unless url =~ %r{\Ahttps?://([^/]+)}i

      # For logging purposes
      domain = $1

      begin
        page = CareersPageProcessor.new.get_careers_page(url)
        raise CareersPageNotFound, "cannot find careers page for #{url}" unless page

        ParsingStats::ParseAttempt.success(domain, url, :website)

        klass = handlers.find { |handler| handler.supports?(page) }
        raise CareersPageNotSupported, "do not know how to find postings for #{page}" unless klass

        handler  = klass.new(page)
        postings = handler.find
        ParsingStats::ParseAttempt.success(domain, url, :careers, handler.name)

        postings
      rescue CareersPageNotFound => e
        ParsingStats::ParseAttempt.failure(domain, url, :website, e.class.name)
        raise
      rescue CareersPageNotSupported => e
        ParsingStats::ParseAttempt.failure(domain, url, :careers, e.class.name)
        raise
      rescue Handlers::Error, ArgumentError => e
        ParsingStats::ParseAttempt.failure(domain, url, :careers, e.to_s)
        raise
      end
    end

    private

    def handlers
      Handlers.constants.each_with_object([]) do |name, list|
        const = Handlers.const_get(name)
        list << const if const.is_a?(Class) && const.respond_to?(:supports?)
      end
    end
  end
end
