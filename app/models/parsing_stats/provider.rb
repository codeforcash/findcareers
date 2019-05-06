class ParsingStats::Provider < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  def calcualte_statistics
    ParsingStats::Website.find_by_sql([<<-SQL, id])
      select w.id, w.domain, p.name provider,
             sum(w.success_count + w.failure_count) total,
             cast(sum(w.success_count) as float)/sum(w.success_count + w.failure_count) success,
             cast(sum(w.failure_count) as float)/sum(w.success_count + w.failure_count) failure
      from parsing_stats_websites w
      left join parsing_stats_providers p on p.id = w.provider_id
      where w.provider_id = ?
      group by w.domain
    SQL
  end
end
