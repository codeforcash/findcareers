require 'rails_helper'

RSpec.describe ParsingStats::Website, type: :model do
  subject { described_class.new(:domain => "example.com") }

  it { is_expected.to validate_presence_of(:domain) }
  it { is_expected.to validate_uniqueness_of(:domain).case_insensitive }
end
