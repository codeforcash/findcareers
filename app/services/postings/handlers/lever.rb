require "uri"
require "lever_postings"

module Postings
  module Handlers
    class Lever
      DOMAIN_NAME_REGEX = %r{\Ajobs\.lever\.co\b}
      DEFAULT_LIMIT = 10

      def self.supports?(name)
        DOMAIN_NAME_REGEX.match?(name)
      end

      ##
      # Create an instance capable of retrieving jobs for website.
      # +website+ is expected to be in the format: +jobs.lever.co/NAME+ where
      # +NAME+ is the company's listings to retrieve.
      #

      def initialize(website)
        raise ArgumentError, "unsupported site #{website}" unless self.class.supports?(website)
        @company = website =~ %r|#{DOMAIN_NAME_REGEX}/(.+)| ? $1 : nil
        raise ArgumentError, "#{website} does not have the company's name in its path" unless @company
      end

      def find(options = nil)
        options ||= {}

        # Not sure if this is what we want to do -yet!
        # limit = options[:per_page] || DEFAULT_LIMIT
        # skip  = (options.include?(:page) ? options[:page] - 1 : 0) * limit

        skip = 0
        postings = []

        loop do
          results = LeverPostings.postings(@company, :skip => skip, :limit => DEFAULT_LIMIT)
          break if results.empty?

          results.each do |posting|
            postings << Posting.new(:title => posting.text,
                                    :description => posting.description,
                                    :url => posting.hostedUrl)
          end

          skip += DEFAULT_LIMIT
        end

        postings
      rescue Faraday::ClientError, LeverPostings::Error => e
        # LeverPostings does not hide rescue/reraise Faraday::ClientError :(
        raise Error, "failed to retrieve Lever postings for #@company: #{e.message}"
      end
    end
  end
end
