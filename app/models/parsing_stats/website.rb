module ParsingStats
  class Website < ApplicationRecord
    belongs_to :provider, :optional => true
    has_many :parse_attempts

    validates_presence_of :domain
    validates_uniqueness_of :domain, :case_sensitive => false


    def self.calculate_statistics
      find_by_sql(<<-SQL)
        select p.name provider_name,
           provider_id,
           sum(w.success_count + w.failure_count) total,
           cast(sum(w.success_count) as float)/sum(w.success_count + w.failure_count) success,
           cast(sum(w.failure_count) as float)/sum(w.success_count + w.failure_count) failure
        from parsing_stats_websites w
        left join parsing_stats_providers p on p.id = w.provider_id
        group by w.provider_id, p.name
        order by p.name
      SQL
    end
  end
end
