class CreateCarriedOverMessage < ActiveRecord::Migration[5.2]
  def change
    create_table :carried_over_messages do |t|
      t.integer :job_id, null: false
      t.datetime :job_created_at, null: false

      t.string :bioguide_id, null: false
      t.string :campaign_tag
      t.text :fields, null: false

      t.string :tags
      t.string :last_status
      t.string :last_screenshot
      t.datetime :last_attempted_at, default: Time.at(0)
      t.integer :attempts, default: 0
      t.boolean :complete, default: false
    end
  end
end
