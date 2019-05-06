module ParsingStats
  class ParseAttempt < ApplicationRecord
    belongs_to :website

    enum :url_type => [ :careers, :website ]

    validates_presence_of :website
    validates_presence_of :url

    class << self
      def success(domain, url, url_type, provider = nil)
        transaction do
          attempt = build_parse_attempt(domain, url, url_type, provider)
          attempt.detected = true
          attempt.website.increment(:success_count)
          attempt.website.save!
          attempt.save!
        end
      end

      def failure(domain, url, url_type, error, provider = nil)
        transaction do
          attempt = build_parse_attempt(domain, url, url_type, provider)
          attempt.detected = false
          attempt.error = error
          attempt.website.increment(:failure_count)
          attempt.website.save!
          attempt.save!
        end
      end

      private

      def build_parse_attempt(domain, url, url_type, provider)
        site = ParsingStats::Website.find_or_create_by(:domain => domain)
        site.provider = ParsingStats::Provider.find_or_create_by(:name => provider) if provider
        site.parse_attempts.build(:url => url, :url_type => url_type)
      end
    end
  end
end
