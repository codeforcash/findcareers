class CreateParsingStatsParseAttempts < ActiveRecord::Migration[5.2]
  def change
    create_table :parsing_stats_parse_attempts do |t|
      t.string :url, :null => false, :limit => 512
      t.integer :url_type, :null => false
      t.boolean :detected, :null => false, :default => false
      t.text :error
      t.timestamps

      t.belongs_to :website, :null => false
    end

    add_foreign_key :parsing_stats_parse_attempts, :parsing_stats_websites, :column => :website_id, :on_delete => :cascade
  end
end
