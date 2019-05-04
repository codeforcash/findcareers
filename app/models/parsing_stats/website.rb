require "uri"

module ParsingStats
  class Website < ApplicationRecord
    belongs_to :provider, :optional => true
    has_many :parse_attempts

    validates_presence_of :domain
    validates_uniqueness_of :domain, :case_sensitive => false
  end
end
