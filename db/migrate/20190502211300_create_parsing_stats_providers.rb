class CreateParsingStatsProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :parsing_stats_providers do |t|
      t.string :name, :limit => 32
      t.timestamps
    end

    add_index :parsing_stats_providers, :name, :unique => true
  end
end
