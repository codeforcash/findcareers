class CreateParsingStatsWebsites < ActiveRecord::Migration[5.2]
  def change
    create_table :parsing_stats_websites do |t|
      t.string :domain, :null => false
      t.integer :success_count, :default => 0, :null => false
      t.integer :failure_count, :default => 0, :null => false
      t.belongs_to :provider
      t.timestamps
    end

    add_index :parsing_stats_websites, :domain, :unique => true
    add_foreign_key :parsing_stats_websites, :parsing_stats_providers, :column => :provider_id, :on_delete => :cascade
  end
end
