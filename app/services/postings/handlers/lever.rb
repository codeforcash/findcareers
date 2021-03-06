# frozen_string_literal: true

require "uri"
require "lever_postings"

module Postings
  module Handlers
    class Lever < Handler
      DOMAIN_NAME = "jobs.lever.co"
      DEFAULT_LIMIT = 10

      def self.supports?(page)
        uri = URI(page)
        uri.host == DOMAIN_NAME
      rescue ArgumentError, URI::InvalidURIError
        false
      end

      ##
      # Create an instance capable of retrieving jobs for website.
      # +website+ is expected to be in the format: +jobs.lever.co/NAME+ where
      # +NAME+ is the company's listings to retrieve.
      #

      def initialize(page)
        raise ArgumentError, "unsupported site #{page}" unless self.class.supports?(page)

        @company = URI(page).path[1..-1]
        raise ArgumentError, "#{page} does not have the company's name in its path" unless @company.present?
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
            postings << Posting.new(posting.text,
                                    posting.description,
                                    posting.hostedUrl)
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
