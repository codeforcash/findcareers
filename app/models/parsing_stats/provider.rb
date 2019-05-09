class ParsingStats::Provider < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  def calculate_statistics
    return [] unless persisted?

    ParsingStats::Website.find_by_sql([<<-SQL, id])
      select w.id, w.domain, p.name provider,
             (w.success_count + w.failure_count) total,
             cast(w.success_count as float)/(w.success_count + w.failure_count) success,
             cast(w.failure_count as float)/(w.success_count + w.failure_count) failure
      from parsing_stats_websites w
      left join parsing_stats_providers p on p.id = w.provider_id
      where w.provider_id = ?
      group by w.domain
      order by w.domain
    SQL
  end
end
