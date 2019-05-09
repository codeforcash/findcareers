class ParsingStats::Provider < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  def calculate_statistics
    ParsingStats::Website.find_by_sql(<<-SQL)
      select w.id, w.domain,
             (w.success_count + w.failure_count) total,
             cast(w.success_count as float)/(w.success_count + w.failure_count) success,
             cast(w.failure_count as float)/(w.success_count + w.failure_count) failure
      from parsing_stats_websites w
      left join parsing_stats_providers p on p.id = w.provider_id
      where w.provider_id #{id ? "= #{id}" : "is null"}
      group by w.domain, w.id, w.success_count, w.failure_count
      order by w.domain
    SQL
  end
end
