class CreateFills < ActiveRecord::Migration[5.2]
  def change
    create_table :fills do |t|
      t.string :bioguide_id, null: false
      t.string :campaign_tag
      t.string :status, null: false
      t.string :screenshot

      t.timestamps
    end

    add_index :fills, :bioguide_id
    add_index :fills, :campaign_tag
    add_index :fills, [:bioguide_id, :status]
  end
end
